import json, os, sys

ambxst_colors = os.path.expanduser('~/.cache/ambxst/colors.json')
wal_dir = os.path.expanduser('~/.cache/wal')
os.makedirs(wal_dir, exist_ok=True)

with open(ambxst_colors) as f:
    colors = json.load(f)

# Map ambxst color names to wal-color order (16 colors)
order = [
    'background',      # color0
    'surfaceVariant',  # color1
    'error',           # color2
    'errorContainer',  # color3
    'green',           # color4
    'greenContainer',  # color5
    'yellow',          # color6
    'yellowContainer', # color7
    'blue',            # color8
    'blueContainer',   # color9
    'magenta',         # color10
    'magentaContainer',# color11
    'cyan',            # color12
    'cyanContainer',   # color13
    'overSurface',     # color14
    'surfaceBright',   # color15
]

wal = []
for key in order:
    wal.append(colors.get(key, '#000000'))

with open(os.path.join(wal_dir, 'colors'), 'w') as f:
    f.write('\n'.join(wal))

with open(os.path.join(wal_dir, 'colors.json'), 'w') as f:
    state = os.path.expanduser('~/.cache/ambxst/wallpapers.json')
    wallpaper = ''
    if os.path.exists(state):
        with open(state) as sf:
            wallpaper = json.load(sf).get('currentWall', '')
    json.dump({'colors': {f'color{i}': wal[i] for i in range(16)},
               'wallpaper': wallpaper}, f)

print(f'wal: {wal[0]} ... ({len(wal)} colors)')
