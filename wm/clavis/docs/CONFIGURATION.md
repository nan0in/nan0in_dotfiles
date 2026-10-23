# 配置结构与定制方法

## 三层职责

- niri：窗口布局、工作区、显示器、输入、快捷键、窗口规则。
- Clavis/Quickshell：顶栏、Dock、通知、启动器、控制中心、壁纸等 UI。
- key-cli：录屏、剪贴板与系统状态等 backend，不是 compositor。

不要把 Ambxst 的生成配置、axctl/hyprctl 调度器或上游 Shell 默认快捷键整份覆盖进来。
用户的明确键位选择优先；相同物理键在多层出现时，后加载配置生效。

## 文件位置

| 路径（相对仓库根） | 用途 | 建议修改方式 |
|---|---|---|
| wm/clavis/UPSTREAM | 上游 URL、固定 commit | 升级合并时更新 |
| wm/clavis/.local/src/clavis/ | 完整上游源码 | UI 改 QML，原生 backend 改 C++ 后 build |
| wm/clavis/.config/niri-clavis/config.kdl | 加载入口 | 保持层次与顺序 |
| personal-base.kdl（同目录） | 既有 niri 快照 | 屏幕/输入等基础差异，谨慎调整 |
| shell-binds.kdl | 兼容旧 include 的空入口 | 不再定义快捷键 |
| clavis/binds.kdl | 已合并的窗口、工作区与 Shell 绑定 | 在 Clavis 快捷键页编辑、删除，或直接编辑运行文件 |
| compat-rules.kdl | 迁移的个人窗口规则 | 只匹配需要的应用 |
| clavis/*.kdl（profile 内） | Clavis UI 可写片段 | 给 UI 的显式设置功能管理 |
| local.kdl | 最后加载的个人层 | 首选手动定制入口，不由安装器重写 |
| settings/ | Shell UI 个人设置 | 首选 Clavis 设置中心；初始 idle policy 单独跟踪 |
| scripts/desktop-actions.py | 全工作区浮动、OCR 等兼容动作 | 配置目录内脚本，不安装 PATH 命令 |
| scripts/keybindings.py | 解析有效 include 链、只读帮助 | 修改配置后同步生成文档 |
| wm/clavis/.config/systemd/user/ | Shell/watch 服务与 niri drop-in | 修改后 daemon-reload；不需重启 niri |

表中没有完整前缀的文件均在 wm/clavis/.config/niri-clavis/ 下。
运行时 `~/.local/src/clavis` 链接到仓库源码；`~/.config/niri-clavis/` 是真实可写目录，
由模板首次部署，之后保留本地修改。请修改运行目录来定制当前桌面；模板用于新部署。
Clavis 的写入保护拒绝软链接路径，因此不再把整个 profile 链接进仓库。
安装记录在 `~/.local/state/clavis/profile-install.json`；只自动更新哈希仍与上次安装一致的文件。
`local.kdl`、`clavis/*.kdl` 和 `settings/*` 永不被后续安装覆盖；卸载也保留运行目录。
原 ~/.config/niri/config.kdl、scripts/、satty/、fuzzel/ 仍保留；它们不是此次新复制的配置。
因此这是一套**本机迁移**，带用户名、双屏参数和对旧个人脚本/服务的依赖，尚非跨机便携发行版。

## 实际加载顺序

```text
personal-base.kdl
  → shell-binds.kdl → compat-rules.kdl
  → startup.sh（仅登录时触发）
  → clavis/{effects,cursor,layer-rules,binds,outputs,minimize-animation,hot-corners}.kdl
  → 会话级 Dracula GTK / qt6ct 管理的 Qt 外观
  → local.kdl（最后）
```

include 顺序按位置合并；窗口规则按位置插入，绑定的同键覆盖不同于“同时执行两条”。
当前默认快捷键仅定义在 `clavis/binds.kdl`，不再由 personal-base / shell-binds 重复定义。
在 Clavis 快捷键页点按键标签编辑，标签右侧 × 删除；同一动作可拥有多个不同按键。
滚轮等伪按键目前不显示在上游快捷键编辑器，仍在同一文件手动修改。
如想固定不交给 UI 管理的最终行为，写 `local.kdl`；它是刻意的外部覆盖，UI 不删除它。
安装器不会再次填回你删除的快捷键，也不把上游 DEFAULT_BINDINGS 填满空片段。

## 示例：在最后一层定制

编辑 ~/.config/niri-clavis/local.kdl；以下是独立示例，不要把整份指南粘贴进去：

```kdl
// 比如个人更喜欢 Dolphin，可只覆盖这一条；当前默认遵循设置中心的文件管理器选择。
binds {
    Mod+E repeat=false { spawn "dolphin"; }
}
```

修改后先运行：

```sh
niri validate -c ~/.config/niri-clavis/config.kdl
```

niri 登录使用这份配置后，相关 KDL 文件修改会被自动监视并重载。
更改 startup.sh / spawn-at-startup 不会使自启程序在当前会话重跑。
本次在旧 niri 会话中修改新配置，也不会把旧桌面自动切成 Clavis。

### niri 的核心个人选择

- 已按用户确认恢复 Super+L 锁屏、Super+J 列显示切换。
- 方向键为主要方向操作，Ctrl 跨屏，Shift 移窗，Ctrl+Shift 窗口跨屏。
- Super+Shift+F 是全工作区浮动，Alt+F 才是平铺/浮动层焦点切换。
- 仍保留 1…10 命名工作区、scratch、原双屏位置/分辨率和猫标光标。
- 默认全局没有模拟 Hyprland layout dispatcher；M/J/P 各自具体含义见迁移对照。

## Shell 主题与壁纸

Super+Shift+C 进入设置。JSON 的路径以 settings/ 下实际生成文件为准；不要把
Ambxst theme.json/config.json 当成 Clavis 的格式直接导入。
QML/UI 源码与用户设置分开；源目录中的 AGENTS.md 也包含后续 QML 定制约定。
本次没有修改上游 QML 业务代码。

Clavis 原生插件从 build/qml 载入，M3Shapes 与额外 Qt 模块从私有依赖目录载入。
这些环境只写在 clavis-shell.service，不改全局 Qt import/LD_LIBRARY_PATH。
改服务文件后执行 systemctl --user daemon-reload，再按需重启 Shell。

## 锁屏与闲置策略

settings/idle-policy.json 关闭 Clavis 自己的 policy，保留已有
niri-idle.service 和 niri-sleep-lock.service。只选一套闲置策略，避免重叠锁定。
Super+L、合盖及两项 swayidle 服务统一使用
`~/.config/niri-clavis/scripts/lock.py`，优先 Clavis 当前锁屏样式。
脚本等待 session-lock 的 secure 状态，不把请求已发出当作锁屏完成；
Clavis 不可用时回退 swaylock，捕获超时时先取消尚未取得锁的请求。
睡眠前使用 `--sleep` 跳过桌面截图；已有截图请求也会提前结束等待。
锁屏成功后由独立监测进程跟踪原始 Shell 实例，崩溃时启动 swaylock 接管，而不是把重启后的“未锁屏”状态当成解锁。
`Super+Alt+L` 为 `allow-when-locked=true` 的独立 swaylock 恢复键，红屏时仍可要求密码解锁。
锁屏时关闭托盘等弹出菜单并抑制 tooltip，避免屏幕重建时映射失效的 popup parent。
两项 niri 服务使用 `80-clavis.conf` drop-in，不修改原服务或旧 niri 脚本。
Clavis 自身 idle policy 继续关闭；真实密码解锁和睡眠恢复仍需手动验收。

## Git 与更新

- settings/ 中除初始 idle-policy.json 外的新运行数据默认忽略；主题定制要纳入 Git 时，
  先检查是否含位置、账号、路径、凭据，再明确选择文件，不整目录强制 add。
- build、天气下载资源和 Python 缓存不进入 Git；原 upstream LICENSE/第三方许可证保留。
- 根 README 已有你的其他未提交修改，本次只插入 niri 文档入口，不重排其余章节。
- 此前旧 niri 快照不会自动同步原配置的后续更改，需要比较并有意合并。

## 完整快捷键文档

Super+F1 是实时只读列表。仓库中的静态清单可重新生成：

```sh
python3 ~/.config/niri-clavis/scripts/keybindings.py --markdown > wm/clavis/docs/KEYBINDINGS.md
```

解析使用随 Clavis 源码提供的 KDL parser，支持 include、后加载覆盖和 Mod/Super 别名。
Clavis 自带 Super+Slash 配置图仍保留；实际完整查阅优先使用 Super+F1。

## 搜索弹出位置

设置 → 通用 → Spotlight → **弹出位置**，支持“跟随状态栏、顶部、居中、底部”。
设置保存在真实运行目录 `~/.config/niri-clavis/settings/ui-preferences.json` 的
`spotlightPosition` 字段，对应值为 `auto`（默认）、`top`、`center`、`bottom`。
推荐使用设置界面；手动编辑时仅修改这个字段，保留其他个人字段。
位置即时生效并跨登录保存，不需要调整 niri 快捷键，也不需要重启桌面。
“居中”是整个搜索面板居中，“底部”将结果放在输入框上方；四种模式目前都水平居中。
若今后定制水平位置或更细的偏移，布局入口是源码中的
`Modules/Launcher/LauncherWindow.qml`，不是 niri 普通窗口的 `window-rule`。

## 系统监控显示为横线

Clavis 消费 key-cli 的原生 JSONL 流。Python wheel **不包含** `key-sysmon` 原生采样器；
只装 wheel 会令 CPU、内存、温度和磁盘全部显示横线。私有依赖安装脚本现在同时构建
同版本、SHA-256 校验过的原生源码，并将采样器放在私有 `key` 命令旁边，不创建会话包装器，
不替换 `/usr/bin` 或个人 PATH 命令。

已有安装仅修复监控依赖：

```sh
./scripts/setup-clavis.sh repair-sysmon
~/.local/opt/nan0in-clavis-deps/key-cli/bin/key sysmon snapshot --format json --modules cpu,memory,disk
# 验证有数值后，仅刷新 Shell，恢复此前耗尽重试次数的订阅：
systemctl --user restart clavis-shell.service
```

初次 CPU 百分比可能等待一个采样周期（默认 2 秒）；温度也需要硬件暴露传感器。
本机已检测到 CPU 温度。未授权的 RAPL 功耗、风扇转速等缺失值仍如实留空，
不为显示功耗更改权限、授予 capability 或增加常驻 root 服务。


## Dracula、动态壁纸与截图

当前桌面采用 Material Dracula Qt 控件与调色板；Clavis 配色来源、Waywallen 只读桥接、
Satty 默认编辑与可选 Spectacle 方式见 [桌面集成说明](DESKTOP-INTEGRATION.md)。

## 快捷键冲突与旧版本迁移

已移除旧层中 29 组被覆盖的重复定义，按原 include 顺序保留最后生效动作；不是同时执行两条。
`Super+L` 锁屏、`Super+J` 切换列显示，方向键导航不变。
按后续要求取消 `Super+Ctrl+V`，同时移除 `Ctrl+Super+A`、`Super+Shift+N`、
`Super+BackSpace`、`Super+Alt+W`、`Super+Ctrl+Comma` 六个冗余入口。
Dashboard 用 `Super+D`，快速设置用 `Super+A`；电源菜单、壁纸、设置分别保留
`Super+Escape`、`Super+Shift+W`、`Super+Shift+C`。
最初的无效 `sidebar` 动作已清理，不会再使整份 niri 配置校验失败。

`sidebar` 不是 niri 原生动作；正确表达式示例：

```kdl
Mod+D repeat=false {
    spawn "qs" "-c" "clavis" "ipc" "call" "sidebar" "toggle" "dashboard";
}
```

现在保存先运行 niri 校验，拒绝无效动作；同一 UI 片段的重复物理按键也拒绝保存
（包含 Mod/Super、Ctrl/Control 和大小写别名），原文件保持不变。
删除或改键不再由旧 personal-base / shell-binds 自动恢复。

只读检查当前 include 链：

```sh
python3 ~/.config/niri-clavis/scripts/keybindings.py --audit
```

输出有效性、按键数量和重复定义来源；无重复且校验成功时退出码为 0，不执行任何绑定。
`local.kdl` 中有意的覆盖也会列出，供你自行决定保留哪一处。

已部署过旧版 profile 的机器应先迁移，再运行普通安装更新（当前机器已经完成）：

```sh
./scripts/setup-clavis.sh migrate-bindings
./scripts/setup-clavis.sh install
```

迁移先在临时 include 图校验，备份相关文件到 `~/.local/state/clavis/bindings-backup-*`，
然后合并已有绑定并保留当前有效动作、属性和自定义绑定；不改原 `~/.config/niri/`。
重复执行迁移为空操作。若旧配置已经存在无效动作，先修正该动作再迁移；迁移失败不会发布候选配置。
新部署直接使用单一绑定片段；已部署 profile 的 `clavis/binds.kdl` 继续由安装器保留。


## Dock 覆盖层与列最大化

Dock 无论位于哪一边、是否开启自动隐藏，都不预留应用工作区；显示它时是临时覆盖窗口，
不挤窄列。设置 → 常规 → Dock 的位置、固定应用与自动隐藏偏好均保留。
`Super+M` 是 niri 的列最大化／恢复，`Super+F` 是窗口全屏，两者不混用。
状态栏是另一独立组件，仍按自己的配置预留空间。

## 单独轻按 Super

私有 niri-edge 已包含 `clavis-native-1` 原生补丁，下次正常 Niri 登录生效。
单独 Super 在 600 ms 内松开才触发；组合键、鼠标、滚轮、触摸、锁屏或快捷键抑制都会取消。
客户端仍收到配对的 Super 按下／松开事件，不吞按键；长按不重复触发。
设置页可填 `Mod`／`Super`，规范保存为 `Super_L`，可正常编辑删除；保留 `Super+Space`。
实现不使用全局按键监听进程，不创建自定义登录会话，也不替换系统 niri。
详见 [私有 compositor](../../niri-edge/README.md)。


## 私有 compositor、Emoji 与开机动画

- 私有 niri-edge 已启用并在本次正常登录运行；[构建和回退](../../niri-edge/README.md)。
  原生最小化和恢复使用异步 IPC，不阻塞面板的 Wayland 事件处理；窗口事件确认最终状态。
- Emoji：`Super+Period` 或 Spotlight `/emoji`。Unicode CLDR 47.0.0 数据包含英文、简体及繁体关键词，
  来源、哈希和 Unicode-3.0 许可证位于源码 `assets/emoji/`；未依赖或改写 Ambxst / Vicinae 的用户数据。
- 登录动画：`clavis-startup.service` 的首帧由真实窗口反馈确认，再启动完整 Shell；
  Shell 的 `startup-shell ready` IPC 确认配置、Dock 和当前 niri 连接就绪后退出覆盖层。
  只在正常启动且 Shell 尚未运行时播放，超时不阻止登录。
- 蓝牙：设置页和快捷设置的开启开关现在处理软 rfkill；硬件阻止仍明确报错。

## Waywallen 后端与绿线兼容设置

设置 → 壁纸 → 桌面壁纸管理器可选择 Waywallen / Quickshell / awww，选择和重载均已验证。
不再根据 Waywallen 进程是否存在来隐藏管理器选择；按实际选中的后端显示原生壁纸和过渡设置。
选择 Waywallen 会隐藏 Clavis 桌面背景表面，保留 Overview / 桌面卡片及全部旧壁纸设置。
切回原生后端不擅自结束外部 Waywallen 进程；需要暂停它时使用它自己的管理界面。
在 Waywallen 后端，上一张／下一张转交其原生 D-Bus 接口；不通过原生文件选择器改写外部壁纸，随机切换不改其队列模式。

当前视频解码已通过 Waywallen 原生 API 改为 `none`；Vulkan → 软件 → Vulkan → 软件对比实测，
绿色最右四列分别出现／消失／出现／消失。VA-API 在本机这一运行环境退回软件，未将它报告成硬解成功。
视频、布局、帧率、每屏选择和其余配置的 TOML 语义均验证未变；软件解码可能增加 CPU 消耗。
原配置备份：`~/.local/state/clavis/completion-20261022-002048/waywallen-config-before-decoder-ab.toml`。
恢复解码选项请在 Waywallen 视频设置中选择 `auto`，不要在运行时用旧配置整文件覆盖后续个人改动。


## 显示器只读与扩展排列

显示器原先只读，是因为输出块来自 `personal-base.kdl`，不属于设置页可写的输出片段；
不是文件权限问题，也不需要 chmod。现已将两块输出原样迁到 `clavis/outputs.kdl`，
保留刷新率、缩放、位置以及 base 的其余内容；真实 niri 输出快照迁移前后完全相同。
迁移有备份，重复执行为空操作；之前已手改的 base 不会因迁移被重新纳入可覆盖文件。

旧部署可在仓库根目录执行：

```sh
python3 scripts/clavis-outputs.py check
./scripts/setup-clavis.sh migrate-outputs
```

本机已经完成。打开 **设置 → 常规 → 显示器 → 配置**，拖动显示器矩形调整左右／上下扩展排列，
或编辑位置与缩放；先预览，确认正常后保留，未确认则回退。本轮只验证了右侧扩展草稿，不替你应用硬件布局。
复制投影已提供于同页“镜像／投影”；使用 wl-mirror，保留扩展布局，不用输出坐标重叠冒充镜像。
