hl.config({
  debug = {
    disable_logs = false,
  },
  gestures = {
    workspace_swipe_distance = 300,
    workspace_swipe_cancel_ratio = 0.5,
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

hl.window_rule({
  name = "ida-toplevels-by-class",
  match = { class = ".*(ida|IDA|hexrays|Hex-Rays).*" },
  tile = true,
})

hl.window_rule({
  name = "ida-toplevels-by-title",
  match = {
    title = ".*(IDA|Hex-Rays|Pseudocode|Disassembly|Functions|Names|Strings|Structures|Enums|Imports|Exports|Segments|Output window|Graph view).*",
  },
  tile = true,
})

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-floating-workspace.sh"))
