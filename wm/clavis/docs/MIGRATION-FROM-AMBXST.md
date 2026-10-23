# 从 Ambxst + Hyprland 迁移：操作习惯与真实差异

日期：2026-10-21。对照来源不是上游默认配置，而是本仓库的：

- `config/.config/hypr/hyprland.conf`：实际仍使用 conf.d 入口。
- `conf.d/00-vars.conf`、`60-binds.conf`、`90-local.conf`：个人程序、快捷键和最后覆盖。
- `config/.config/ambxst/binds.json`、`hypr/lua/binds.lua`：补充 Ambxst 面板动作语义。
- 本机现有 niri 配置：保留显示器、窗口规则、截图、工作区等迁移成果。

conf.d 的注释与旧 Lua 不完全一致时，优先看实际 conf.d 与当前脚本。
本次不修改这些旧文件；调整仅写入新的 niri-clavis 配置。

## 已按个人习惯调整

| 按键/操作 | 原来的意图 | 新配置 | 状态/差异 |
|---|---|---|---|
| Super+Q / Enter | Kitty | Kitty | 保留；Enter 为 niri 额外入口 |
| Super+W | 关闭当前窗口 | close-window | 同用途 |
| Super+E | Thunar | **打开默认文件管理器** | 跟随设置 → 常规 → 默认应用；当前选择 Dolphin |
| Super+Space | 启动器 | Clavis Spotlight | 同用途；不是原 Hyprlauncher |
| 单独 Super | Ambxst launcher | 不绑定 | 避免组合键误触；使用 Super+Space 打开 Spotlight |
| Super+D | Dashboard | **Clavis 信息 Dashboard** | 不再映射成快速设置；快速设置用 Super+A |
| Super+V | 剪贴板面板 | Clavis 剪贴板 | 新历史由 key/cliphist 管理，不导入旧历史 |
| Super+Period | Emoji | **Clavis Spotlight Emoji** | 内置中英关键词搜索并复制；Vicinae 安装和配置保留 |
| Super+N | 笔记 | **Kitty + Neovim 随手记** | 不是 Ambxst Notes 面板；文件见下文 |
| Super+Shift+N | 第一轮 niri 的通知勿扰 | 已移除冗余侧栏入口 | 通知侧栏用 Super+D；勿扰从 UI 操作 |
| Super+T | tmux 入口 | Kitty tmux main 会话 | 不重建 Ambxst tmux 选择器 |
| Super+Shift+W | 壁纸选择 | Clavis 壁纸页 | 不被上游同键 Keystone hub 覆盖 |
| Super+Shift+C | 设置 | Clavis 设置中心 | 同用途；最后个人覆盖仍写 local.kdl |
| Super+Tab | 总览 | niri 原生总览 | 界面/窗口排列不是 Ambxst Overview |
| Super+Escape | 电源菜单 | Clavis 电源菜单 | 锁屏/挂起链路还需主会话验收 |
| **Super+L** | 锁屏 | **Clavis 样式锁屏，swaylock 兜底** | 按用户选择恢复；Super+Alt+L 同样可用 |
| **Super+J** | togglesplit | **切换当前列普通/标签显示** | 恢复“布局显示切换”用途，不是 dwindle 分割方向 |
| Super+Shift+V | 单窗浮动 | niri 单窗浮动 | 仍为当前窗口；几何由 niri 维护 |
| **Super+Shift+F** | 当前工作区全浮动/恢复 | **当前工作区整体浮动切换** | 修正第一轮 niri 中被用作浮动层焦点切换的差异 |
| Super+Alt+F | 新增便捷入口 | 浮动/平铺层焦点切换 | 原先 Shift+F 的 niri 动作移到这里 |
| Super+Alt+B | Ambxst reload | 重启 Clavis 和剪贴板服务 | 不重启 niri、不动旧 Hyprland |
| **Super+Shift+B** | 托盘恢复 | **重启 Clavis，重新注册本会话托盘应用** | 不再只是 Shell 普通 restart；不按名字跨会话 pkill |
| Super+Ctrl+Alt+B | 第一轮 niri 的停止面板 | 停 Clavis 和 watcher | 保留应急功能；窗口/终端不依赖 Shell |
| **Super+Shift+R** | 录屏面板 | **区域录屏开始/停止** | 不再只打开 OBS；默认不采集音频，使用 key-cli |
| Super+R / Print | 截图 | niri 捕获 + Spectacle 编辑 | Ctrl/Alt+Print 为屏幕/窗口；Shift+Print 菜单保留 Satty 备用 |
| **Super+Shift+A** | Lens | **区域 OCR 复制文字** | 简体中文+英文；仅恢复文字识别，不是完整 Lens 搜图/翻译 |
| **Super+F1** | 全部快捷键帮助 | **读取新 include 链的最终绑定** | 不再显示旧 config.kdl 的过时列表；选择不执行命令 |

## 方向键与布局：最重要的认知差异

按用户明确选择，**方向导航主要用方向键**，不再宣称 Super+HJKL 完全等价。
Super+J/L 已分别恢复布局显示切换、锁屏；其余历史 H/K 与修饰键 HJKL 仍作为补充。

| 按键 | 新配置行为 |
|---|---|
| Super+←/→ | 同屏列焦点左右移动 |
| Super+↑/↓ | 当前列中上下窗口焦点 |
| Super+Shift+←/→ | 单窗并入/移出相邻列，不是移动整列 |
| Super+Shift+↑/↓ | 列内移动当前窗口 |
| Super+Ctrl+方向键 | 跨对应方向显示器聚焦 |
| Super+Ctrl+Shift+方向键 | 当前窗口送到对应方向显示器 |
| Super+Alt+方向键 | 列宽/窗高按 50 像素步进调整 |
| Super+J / Ctrl+T | 当前列普通堆叠与标签显示切换 |
| Super+M | 最大化/恢复当前列宽 |
| Super+F | 当前窗口全屏 |
| Super+P | 列宽预设 1/3 → 1/2 → 2/3 |

Hyprland 的 `dwindle → master → monocle → float` 没有对应的 niri 全局布局循环。
因此 **Super+M 不模拟或伪报原循环**，改为最大化列；标签显示仅作用于当前列，
不是把整个工作区变成 monocle。Super+Shift+F 只转换当前已存在的窗口，
不设置“以后新窗口永远浮动”的工作区规则，返回平铺也不还原原来的列拓扑。
混合工作区首次按键统一浮动；全浮动时按键统一平铺，并尽量保留原焦点。

niri 的浮动层位于平铺层之上，不随平铺画布横向滚动。Super+鼠标拖动/调整由
niri 原生交互处理，不复制 Hyprland bindm 调度器。

## 工作区与 scratch

- Super+1…9/0：命名工作区 1…10；Shift+数字送窗并跟随，Alt+数字静默送窗。
- Super+Shift+Z/X、Super+滚轮：上下切换工作区。niri 的工作区排列是垂直的，
  不照搬 Hyprland 三指水平 workspace 手势；niri 手势由 compositor 本身决定。
- Super+S：进入/返回 scratch；Super+Shift+S / Alt+V：送入 scratch，不跟随。
- scratch 是普通命名工作区，不是 Hyprland `special:magic` 的叠加层。
- Alt+Tab/Alt+Shift+Tab：当前工作区按布局顺序循环，不是全局最近使用 MRU。

## 笔记、Emoji、录屏、OCR 数据

- 新随手记：`~/.local/share/niri-clavis/notes.md`（尊重 XDG_DATA_HOME）。
  首次使用才创建，之后只交给编辑器打开；不覆盖已有内容。
- 旧 Ambxst 笔记在 `~/.local/share/ambxst-notes/`（如原来存在）。
  本次不编辑、删除或重建其 index.json；需要时人工复制 Markdown 内容到新笔记。
- Emoji 已进入 Spotlight，`Super+Period` 或 `/emoji` 直接使用；不再为此启动 Vicinae。
  保留其原安装和设置，不删除旧剪贴板历史。
- 录屏走独立 key-cli，保存目录以 backend 返回值/Clavis 录屏界面为准；按键启动
  区域选择，按第二次停止，切换中的重复请求不执行。没有自动录音或全屏开录。
- OCR 先选择区域，文字复制到剪贴板；临时 PNG 放 0700 runtime 目录，结束自动删除。
  取消选择后最多等待 120 秒，等待期间同一按键不会另开任务。
- **原生截图的未标注图片、OCR 文字都可能进入剪贴板历史**。遮挡/删除临时文件不等于
  清除历史；敏感内容应先暂停 watcher，结束后检查/清除相应历史。

## 拱心石工具的迁移差异

Ambxst 工具入口已加入 Clavis 的悬停工具网格，保留原录制/取色工具。
计算器进入现有 Spotlight；单位换算使用 qalc 交互终端，而不是把不支持单位的
Spotlight 数学表达式当成换算器。当前默认终端入口未安装时使用原有 Kitty。

截图继续使用 niri/grim + Spectacle 标注流程；截图目录跟随 XDG，录屏目录跟随
Clavis 录制设置。新增工具内的 OCR／二维码用 slurp 选择、grim 捕获，取消立即返回；
原 OCR 快捷键的 niri 原生选择器仍保留原逻辑，取消时等待上限 120 秒。

Google Lens 改为浏览器中手动选图，不迁移旧自动上传流程。
镜子默认停止，用户点击播放后仅作本地镜像预览，关闭后停止；本轮未采集真实摄像头。
通知展示与客户端生命周期分离：拱石最多展开 7 秒，历史、未读数和长通知的原始生命周期保留。

## 自启、硬件、外观

保留双屏参数、光标、输入法和已有窗口规则，新增 IDA/Hex-Rays app-id 的默认平铺规则。
应用内部 dock/tab 不是 Wayland 顶层窗口，不由 compositor 分开平铺；不复用旧配置中
范围过宽的通用 Output/Strings 标题规则，以免影响其他应用。

启动保留 fcitx5、polkit、Wi-Fi/蓝牙/cc-switch 托盘应用及原 swayidle 锁屏。
不自动执行旧 Hyprland 的 rfkill unblock / bluetoothctl power on，避免登录时改变
用户的飞行模式/蓝牙电源选择。旧规则如需保留，可显式加到个人 startup.sh。

Clavis 面板、通知替代旧 niri 的 Waybar/Mako；壁纸目前仍选择 Waywallen，亦可切回内置方案。不运行 Ambxst，
也不混搭两套通知服务。音量/亮度键独立执行 wpctl/brightnessctl，OSD 由 Clavis 观察。
主题不会自动复制 Ambxst 的全部 JSON、动画或 matugen 输出；可在 Clavis UI 定制。
锁屏入口统一到 Clavis 当前样式，swaylock 仅作故障兜底；Clavis idle policy 保持关闭，避免两套闲置策略。

## 参考

- [niri 按键与动作](https://niri-wm.github.io/niri/Configuration:-Key-Bindings.html)
- [niri include 与覆盖顺序](https://niri-wm.github.io/niri/Configuration:-Include.html)
- [niri 浮动层](https://niri-wm.github.io/niri/Floating-Windows.html)
- 本地 Clavis 源码 `docs/ipc.md` 与 `scripts/system/niri-actions.json` 为 IPC 实际依据。

Context7 本次返回月度配额耗尽；配置语法改由官方文档、已安装 niri 26.04 帮助和本机
`niri validate` 核实，未凭空添加 Clavis 的 notes/emoji/DND IPC。
