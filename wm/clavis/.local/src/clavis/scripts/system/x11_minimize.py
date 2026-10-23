#!/usr/bin/env python3
"""Forward X11 ICCCM iconify requests to native Niri minimization.

xwayland-satellite 0.8.3 ignores WM_CHANGE_STATE. Listen alongside it without
claiming the window-manager redirect selection or capturing keyboard input.
Only an unambiguous class + title match owned by satellite can be minimized.
"""
import argparse
import ctypes as C
import ctypes.util
import json
import os
from pathlib import Path
import select
import signal
import subprocess
import sys
import time


class ClientData(C.Union):
    _fields_ = [('b', C.c_char * 20), ('s', C.c_short * 10), ('l', C.c_long * 5)]


class ClientMessage(C.Structure):
    _fields_ = [('type', C.c_int), ('serial', C.c_ulong), ('send_event', C.c_int),
                ('display', C.c_void_p), ('window', C.c_ulong),
                ('message_type', C.c_ulong), ('format', C.c_int), ('data', ClientData)]


class Event(C.Union):
    _fields_ = [('type', C.c_int), ('client', ClientMessage), ('pad', C.c_long * 24)]


def satellite_window(window):
    pid = window.get('pid')
    if not isinstance(pid, int) or pid <= 0:
        return False
    try:
        return Path(f'/proc/{pid}/exe').resolve(strict=True).name.startswith('xwayland-satellite')
    except OSError:
        return False


def select_window(windows, wm_class, title, belongs_to_satellite=satellite_window):
    if not wm_class or not title:
        return None
    candidates = [w for w in windows if str(w.get('app_id') or '').casefold() == wm_class.casefold()
                  and w.get('title') == title and belongs_to_satellite(w)]
    if len(candidates) != 1:
        return None
    window = candidates[0]
    return window if isinstance(window.get('id'), int) and window['id'] > 0 else None


class X11:
    def __init__(self):
        library = ctypes.util.find_library('X11')
        if not library:
            raise RuntimeError('libX11 is missing')
        self.lib = C.CDLL(library)
        signatures = {
            'XOpenDisplay': ([C.c_char_p], C.c_void_p),
            'XDefaultRootWindow': ([C.c_void_p], C.c_ulong),
            'XInternAtom': ([C.c_void_p, C.c_char_p, C.c_int], C.c_ulong),
            'XConnectionNumber': ([C.c_void_p], C.c_int),
            'XSelectInput': ([C.c_void_p, C.c_ulong, C.c_long], C.c_int),
            'XFlush': ([C.c_void_p], C.c_int),
            'XPending': ([C.c_void_p], C.c_int),
            'XNextEvent': ([C.c_void_p, C.POINTER(Event)], C.c_int),
            'XGetWindowProperty': ([C.c_void_p, C.c_ulong, C.c_ulong, C.c_long, C.c_long,
                                   C.c_int, C.c_ulong, C.POINTER(C.c_ulong), C.POINTER(C.c_int),
                                   C.POINTER(C.c_ulong), C.POINTER(C.c_ulong), C.POINTER(C.c_void_p)], C.c_int),
            'XFree': ([C.c_void_p], C.c_int),
            'XCloseDisplay': ([C.c_void_p], C.c_int),
        }
        for name, (args, result) in signatures.items():
            function = getattr(self.lib, name)
            function.argtypes, function.restype = args, result
        self.display = self.lib.XOpenDisplay(None)
        if not self.display:
            raise RuntimeError('Could not connect to the session X display')
        # A client can disappear between its message and our metadata read.
        self.error_handler = C.CFUNCTYPE(C.c_int, C.c_void_p, C.c_void_p)(lambda _d, _e: 0)
        self.lib.XSetErrorHandler.argtypes = [C.c_void_p]
        self.lib.XSetErrorHandler.restype = C.c_void_p
        self.lib.XSetErrorHandler(C.cast(self.error_handler, C.c_void_p))
        self.root = self.lib.XDefaultRootWindow(self.display)
        self.change_state = self.atom('WM_CHANGE_STATE')
        self.fd = self.lib.XConnectionNumber(self.display)
        # SubstructureNotify is shared. Never request SubstructureRedirect.
        self.lib.XSelectInput(self.display, self.root, 1 << 19)
        self.lib.XFlush(self.display)

    def atom(self, name):
        return self.lib.XInternAtom(self.display, name.encode(), False)

    def property(self, window, name):
        kind, fmt, count, remaining, data = C.c_ulong(), C.c_int(), C.c_ulong(), C.c_ulong(), C.c_void_p()
        result = self.lib.XGetWindowProperty(self.display, window, self.atom(name), 0, 1024, False, 0,
                                             C.byref(kind), C.byref(fmt), C.byref(count),
                                             C.byref(remaining), C.byref(data))
        try:
            return C.string_at(data, count.value) if result == 0 and data.value and fmt.value == 8 else b''
        finally:
            if data.value:
                self.lib.XFree(data)

    def identity(self, window):
        fields = [part for part in self.property(window, 'WM_CLASS').split(b'\0') if part]
        wm_class = fields[-1].decode('utf-8', errors='replace') if fields else ''
        title = self.property(window, '_NET_WM_NAME') or self.property(window, 'WM_NAME')
        return wm_class, title.rstrip(b'\0').decode('utf-8', errors='replace')

    def close(self):
        if self.display:
            self.lib.XCloseDisplay(self.display)
            self.display = None


def forward(niri, x11, xid):
    wm_class, title = x11.identity(xid)
    if not wm_class or not title:
        return False
    response = subprocess.check_output([niri, 'msg', '--json', 'windows'], text=True, timeout=3)
    window = select_window(json.loads(response), wm_class, title)
    if window is None:
        print('Skipped an unmatched or ambiguous X11 minimize request', file=sys.stderr, flush=True)
        return False
    if window.get('is_minimized'):
        return True
    subprocess.run([niri, 'msg', 'action', 'minimize-window', '--id', str(window['id'])],
                   check=True, capture_output=True, text=True, timeout=3)
    print(f'Forwarded X11 minimize to Niri window {window["id"]}', flush=True)
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--niri', default='niri')
    args = parser.parse_args()
    if not os.environ.get('NIRI_SOCKET'):
        raise RuntimeError('NIRI_SOCKET is missing')
    x11 = X11()
    running = True

    def stop(_signal, _frame):
        nonlocal running
        running = False

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    print('X11 minimize bridge ready', flush=True)
    last_request = {}
    try:
        while running:
            if not x11.lib.XPending(x11.display):
                select.select([x11.fd], [], [], 1)
            while running and x11.lib.XPending(x11.display):
                event = Event()
                x11.lib.XNextEvent(x11.display, C.byref(event))
                message = event.client
                if event.type != 33 or message.message_type != x11.change_state or message.format != 32 or message.data.l[0] != 3:
                    continue
                now = time.monotonic()
                if now - last_request.get(message.window, 0) < 0.2:
                    continue
                last_request = {window: stamp for window, stamp in last_request.items() if now - stamp < 2}
                last_request[message.window] = now
                try:
                    forward(args.niri, x11, message.window)
                except (OSError, ValueError, subprocess.SubprocessError) as error:
                    print(f'X11 minimize failed: {type(error).__name__}', file=sys.stderr, flush=True)
    finally:
        x11.close()
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
