# niri + Clavis：安装、定制与日常使用

## 1. 桌面的组成

- **niri**：窗口、工作区、显示器、快捷键、截图与焦点。
- **Clavis**：状态栏、Dock、搜索、通知、快捷设置、中间拱石、壁纸与设置中心。
- **Ambxst / Hyprland**：保留的旧桌面；不与 Clavis 同时启动。
- **Quickshell / Qt**：Clavis 的运行框架。Clavis 不是另一个 niri 二进制或登录 session。

普通登录界面选择 **Niri** 就使用这套配置，无自定义启动命令。
目录现在统一为 `wm/clavis/`、`wm/ambxst/`，原个人 Hyprland/Ambxst 配置仍在 `config` 包中。

## 2. 安装与更新（仓库根目录执行）

```sh
./scripts/setup-clavis.sh check
./scripts/setup-clavis.sh deps
./scripts/setup-clavis.sh appearance  # Dracula；保留字体、图标和旧 Kvantum
./scripts/setup-clavis.sh build
./scripts/setup-clavis.sh install
niri validate -c ~/.config/niri-clavis/config.kdl
```

`deps` 下载、验签并安装私有依赖到 `~/.local/opt/nan0in-clavis-deps/`，不替换系统 Qt。
Qt 升级后需重新构建。源码来源、固定提交与许可证在 `wm/clavis/UPSTREAM` 和源码目录中。
这是本地源码分支，不代表已创建 GitHub 远端 fork。

`install` 只管理已登记的文件和链接：

- 源码链接稳定为 `~/.local/src/clavis/` 和 `~/.config/quickshell/clavis/`。
- niri 配置首次复制到真实目录 `~/.config/niri-clavis/`，解决上游拒绝写入软链接路径的问题。
- 后续只更新内容仍等于上次安装哈希的管理文件；发现手改就打印 `PRESERVE`。
- `local.kdl`、`clavis/*.kdl`、`settings/*` 已存在就保留。`local.kdl` 是推荐个人覆盖入口。
- 存在不属于本安装的路径则先停止，不采用 `stow --adopt` 或强制覆盖。
- 安装器不重启桌面。需要刷新界面：`systemctl --user restart clavis-shell.service`。
- 当前原始 `~/.config/niri/` 完整保留；原截图、scratch 等脚本仍从这里调用；Clavis 锁屏使用独立入口，旧锁屏脚本保留。

Ambxst 的旧包名继续有效：`./install.sh stow ambxst`；实际使用 `wm/` 作为 Stow 包根。
不要对整个 `wm/` 运行 Stow，也不要对整个 Clavis 包盲目 Stow。

## 3. 先找到状态栏和设置

| 入口 | 动作 |
|---|---|
| `Super+Ctrl+B` | 直接进入状态栏设置，开启“显示栏”、选择上下左右与模块 |
| `Super+Shift+C` | 打开设置中心 |
| `Super+Space` | 搜索／启动应用；下次登录亦可轻按 Super 松开打开，组合键不触发 |
| `Super+Period` | Spotlight 内的 Emoji 搜索；选择后复制并关闭 |
| `Super+A` | 快捷设置侧栏 |
| `Super+D` | 打开／关闭 Dashboard 侧栏 |
| `Super+Ctrl+N` | 网络连接设置 |
| `Super+F1` | 读取当前有效配置的全部快捷键 |
| `Super+Alt+B` | 刷新 Clavis 和剪贴板服务，不重启 niri |

状态栏、Dock、拱石是**三个独立组件**：

- 栏：设置 → 常规 → 栏；模块可移除、添加、排序。
- Dock：设置 → 常规 → Dock，显示应用、固定项目和文件夹；始终覆盖而不挤占应用空间，关闭自动隐藏也一样。
- 拱石：设置 → Keystone／拱石，选择时钟、媒体与工具的布局和位置。

搜索位置可在 **设置 → 通用 → Spotlight → 弹出位置** 修改：

- **跟随状态栏**（默认）：底部栏向上展开，其他位置保留上方搜索布局。
- **顶部 / 居中 / 底部**：独立于状态栏位置；底部结果向上展开，顶部与居中向下展开。
- 修改即时生效并保存，下次登录保留；应用、文件、剪贴板和计算器共用这个位置。

可直接打开该设置页：`qs -c clavis ipc call control-center open general.spotlight`。

单独轻按 Super 的原生实现已安装到私有 niri-edge，**下次正常 Niri 登录生效**。
松开时才触发，组合键、鼠标操作、长按与锁屏状态不触发；保留 `Super+Space` 备用。
设置页可填 `Mod`／`Super`，保存为 `Super_L`，绑定仍可修改／删除，不使用全局监听服务。
见 [单独轻按 Super](CONFIGURATION.md#单独轻按-super)。

栏与拱石处在同一水平边时，左右模块会按可用空间收紧，为中间拱石预留空位。
通知／快捷设置仍是**左右侧栏**，不是向下弹出的应用菜单。

命令行救援入口：

```sh
systemctl --user start clavis-shell.service
qs -c clavis ipc call control-center open general.bar
journalctl --user -u clavis-shell.service -b -n 100 --no-pager
```

### 悬停工具与通知恢复

拱石设为悬停打开“工具”后，横向为 7 列 × 2 行，侧边为 2 列 × 7 行。
方向键按网格移动，Enter 执行。也可用 `qs -c clavis ipc call keystone tools` 开关工具。

| 工具 | 当前行为 |
|---|---|
| 计算器 | 打开 Spotlight `/calc` |
| 单位换算 | 启动 qalc 交互终端；例如 `10 cm to in`，`quit` 退出。优先默认终端入口，当前使用现有 Kitty 兜底 |
| 截图 | 打开截图模式菜单，由 niri/grim 捕获，再交给 **Satty** 编辑标注；菜单可手动选 Spectacle |
| 截图文件夹 | 打开 XDG 图片目录下的 Screenshots，跟随系统默认文件管理器（当前 Nautilus） |
| 录屏文件夹 | 打开 Clavis 设置中的视频录制目录，而非硬编码旧目录 |
| OCR / 二维码 | 框选区域、本地识别、复制；取消不改剪贴板。OCR 使用简体中文和英文 |
| Google Lens | 打开浏览器，由你手动选择并上传图片；不会自动上传桌面截图 |
| 镜子 | 打开镜像预览窗口，点击播放才启动摄像头；关闭即停，无录制、麦克风或上传 |
| 原有取色、视频/GIF/麦克风/系统声音录制 | 保留，仍使用既有录制服务 |

OCR／二维码只临时保存框选图像，结束即删除；复制结果可能进入你已启用的剪贴板历史。
工具运行错误写入 `~/.local/state/clavis/desktop-tools.log`。
相应可选依赖为 libqalculate、slurp、grim、tesseract、英语／简体中文识别数据、
zbar、xdg-user-dirs、Qt Multimedia；本机均已存在，本轮未全局安装依赖。
镜子窗口和默认关闭状态已验证；真实摄像头画面未在本轮开启或截图保存。

通知提示最多展开 7 秒后恢复拱石，短通知遵循更短的客户端超时。
长通知／永久通知只收起临时展示，不清空历史、不标记已读，也不提前关闭客户端通知。
复制投影已列入待实现项，当前左右／上下排列不等于镜像显示。

### CPU / 内存 / 温度显示横线

安装现在会同时补齐 key-cli 的原生采样器，详见 [监控排障](CONFIGURATION.md#系统监控显示为横线)。
旧安装可执行 `./scripts/setup-clavis.sh repair-sysmon`；验证数据后仅刷新 Clavis。
默认采样间隔 2 秒，刚启动时 CPU 百分比可能等待一个周期，不使用假数据填充。

### Dracula / Waywallen / 截图的新入口

- **设置 → 主题 → 配色来源**：强调色或壁纸；默认 Dracula 紫，不必替换动态壁纸。
- **设置 → 壁纸 → 桌面壁纸管理器**：可选 Waywallen / Quickshell / awww；Waywallen 预览、管理和取色仍保留，`Super+Ctrl+Shift+W` 直达。
- **Print / Super+R**：niri 截图后在 Satty 编辑；**Shift+Print** 打开延迟、全屏、鼠标和 Spectacle 可选菜单。
- Qt 控件改为 Material Dracula，Dolphin 单独同步深色配色和图标；GTK 与个人字体保留。

详见 [桌面外观、动态壁纸和截图](DESKTOP-INTEGRATION.md)。

## 4. niri 的基本操作

niri 的平铺是横向滚动的“列”，不是 Hyprland 的 dwindle 二叉树。
窗口进列，列排列在工作区中；列可含多个窗口，并可切成标签式显示。

| 操作 | 键位 |
|---|---|
| 开终端 | `Super+Q` / `Super+Enter` |
| 关窗口 | `Super+W` |
| 列／窗口方向切换 | `Super+方向键` |
| 移动窗口／列 | `Super+Shift+方向键` |
| 切工作区 | `Super+1…9`（其余键位见 F1） |
| 把窗口送到指定工作区 | `Super+Shift+1…9` |
| 跨显示器聚焦 | `Super+Ctrl+方向键` |
| 窗口跨显示器 | `Super+Ctrl+Shift+方向键` |
| 列普通／标签显示切换 | **`Super+J`** |
| 锁屏 | **`Super+L`**，使用设置中的 Clavis 样式，swaylock 兜底 |
| 工作区全部浮动／全部平铺 | `Super+Shift+F` |
| 浮动／平铺区域切换焦点 | `Super+Alt+F` |
| 列最大化 | `Super+M` |
| 文件管理器 | `Super+E`，遵循默认应用设置 |
| OCR / 区域录屏 | `Super+Shift+A` / `Super+Shift+R`；录屏同键停止 |

工作区整体浮动再平铺不保证还原原列分组；J 也不是完整布局算法循环。
保留原 scratch 机制，但不会把普通最小化偷偷等同于移动到隐藏工作区。
快捷键现在统一在 Clavis 设置的快捷键页编辑／删除；不会被旧绑定恢复。
手动添加过 `local.kdl` 覆盖的键仍由该文件管理。

参考 [全部有效快捷键](KEYBINDINGS.md) 和 [Ambxst 差异表](MIGRATION-FROM-AMBXST.md)。

## 5. 文件夹和默认应用

当前默认文件管理器是 **Nautilus（文件）**。`Super+E`、拱石工具及 Dock／Shell 的本地文件夹入口，
先由 GIO 按系统 `inode/directory` 默认关联打开，不再写死 Thunar。
默认处理器命令失败／缺失时才依次尝试 Nautilus → Thunar → Dolphin。

以后在 **设置 → 常规 → 默认应用 → 文件管理器** 选择；重开该页会读取当前系统值。
旧 `~/.config/niri-mimeapps.list` 中强制 Dolphin 的目录项已单独移除，其他行保留，
因此设置页／`xdg-mime` 的修改不再被高优先级覆盖。Nautilus 自身的偏好设置没有被改动。
具体 GUI、命令、视图／隐藏文件配置与备份见 [Nautilus 配置教程](NAUTILUS.md)。

## 6. 托盘与最小化

设置 → 常规 → 栏 → **常驻托盘图标**：开启的常驻外侧，其余放进折叠区。
也可**鼠标中键点击托盘图标**在两区之间切换。选择持久化在 `settings/tray.json`。
列表按应用实际注册的托盘 ID 展示；尚未启动、未注册托盘图标的程序不会出现。

“最小化到托盘”由应用自身实现，例如聊天／同步程序要在自己的设置里开启该选项。
应用自带托盘模式控制窗口何时隐藏，Clavis 控制其图标位置；另提供下述无托盘窗口折叠策略。
本机正常 Niri 登录现已使用私有 niri-edge，Dock 可原生最小化／恢复；保留发行版 niri，
不伪装成隐藏工作区，不创建自定义登录 session 或启动包装命令。安装与回退见
[私有 compositor 说明](../../niri-edge/README.md)。无托盘程序现可在“折叠最小化程序”中选择，详见文末操作说明。

## 7. 网络、连接与蓝牙

本机 NetworkManager、bluetooth 服务运行中，已经有网络管理界面，不需要再装另一套面板。

- `Super+Ctrl+N`：Wi-Fi／已保存连接／有线连接相关设置；认证走保留的 polkit agent。
- `Super+A`：网络、蓝牙、音频、亮度快捷开关；图标旁的详情进入连接列表。
- 托盘 `nm-applet`：备用的 NetworkManager 图形入口。
- `nm-connection-editor`：更完整的连接配置，适合静态 IP、DNS、VPN 等高级项目。
- `nmtui`：无图形面板时的终端连接编辑工具。
- 蓝牙可从快捷设置进入配对页面；已有 blueman 托盘也保留。

只读诊断：

```sh
nmcli general status
nmcli device status
nmcli connection show --active
systemctl is-active NetworkManager bluetooth
```

不在文档示例中保存 Wi-Fi 密码；VPN 需对应类型的 NetworkManager 插件。
官方说明：[nmcli](https://networkmanager.pages.freedesktop.org/NetworkManager/NetworkManager/nmcli.html)、
[nmtui](https://networkmanager.pages.freedesktop.org/NetworkManager/NetworkManager/nmtui.html)。
Clavis 云盘页需要额外 rclone；它不是网络连接服务，不会为解决联网问题自动安装或创建远端。

## 8. 字体与主题

顶部中文日期单独使用已安装的 **Noto Sans CJK SC**，缺字时回退 UI 字体；数字时钟仍用原 Google Sans Flex。
不改你选择的霞鹜文楷 UI／等宽字体。字体角色定义在源码 `Common/Fonts.qml`。

niri 保留 `QT_QPA_PLATFORMTHEME=qt6ct`；不再固定 `GTK_THEME`／`QT_STYLE_OVERRIDE`，
避免会话变量覆盖你在设置页的选择。

**设置 → 主题 → 应用外观**：GTK3 主题、应用图标、Qt6 控件样式／配色、Kvantum 主题均可选择，
显示当前方案描述。GTK3 已应用 **Clavis Material Dracula**，基于 adw-gtk3-dark 的圆角 Dracula 皮肤；
Qt6 保留现有 Kvantum Material Dracula。只改必要配置项，个人字体、字号、视图和其他设置保留。
GTK 选择同步 settings.ini、Wayland 的 GSettings 与现有 XSettings 主题键；图标同理同步。
已分别用实际 GTK Wayland／X11 后端确认 Material Dracula，字体保持各自原值。
Kvantum SVG 主题与 Qt 调色板是两层，选 Kvantum 时以其主题为主；Qt5 不在本次控制范围内。
GTK4/libadwaita、自绘应用及沙箱应用各有主题机制，不强制注入 CSS。
已打开的应用需自行退出重开；刷新 Clavis 不关闭你的应用，Thunar 后台实例也可能需要自行退出再开。
新外观修改留存于 `~/.local/state/clavis/appearance-backups/`；原主题资源不改。

## 9. 保存个人定制

1. 修改 `~/.config/niri-clavis/local.kdl`，而非原 `~/.config/niri/config.kdl`。
2. 验证 `niri validate -c ~/.config/niri-clavis/config.kdl`；成功后 niri 监控配置自动重载。
3. Clavis UI 设置保存于 `~/.config/niri-clavis/settings/`，不进入 Git。
4. 要把通用改动收回 dotfiles，手动比较并选择性合并到 `wm/clavis/.config/niri-clavis/`。
   不要整目录同步个人数据；这是为了避免提交隐私和下次部署覆盖。
5. 改 QML 源码按源码 AGENTS 先格式化、再 scoped check；C++／翻译改动需重新构建。

迁移备份位于 `~/.local/state/clavis/wm-migration-*/` 和 `profile-backup-*/`。
迁移前 build 留作回滚记录，包含旧绝对路径；要恢复源码路径应重新构建，而不是复用旧 CMakeCache。

## 10. 排障和回退

- 配置只读：`test ! -L ~/.config/niri-clavis`，并查看 helper 的 `diagnostics.writable`；不要绕过安全检查或 chmod 777。
- 栏不见：用 `Super+Ctrl+B` 开“显示栏”；检查栏的模块区是否被清空；查看 Shell 服务状态。
- 搜索误触：单独 Super 绑定已移除；若个人 `local.kdl` 又绑定了它，请自行移除那条覆盖。
- 网络有设备无界面：使用 `nm-applet` / `nmtui`；不要重启 NetworkManager 影响当前连接。
- 通知／托盘失灵：`Super+Shift+B` 恢复托盘；若仅 UI 异常，优先 `Super+Alt+B`。
- Qt 更新后导入失败：重新 `deps`、`build`，再刷新 Shell。

回到原桌面：仓库根目录执行 `./scripts/setup-clavis.sh uninstall`，保存工作，正常注销再选 Niri。
卸载移除本安装链接和 niri drop-in，**保留运行配置、所有个人设置、源码和依赖**；不重启当前 niri。
更多日志路径和细节见 [USAGE](USAGE.md)、[CONFIGURATION](CONFIGURATION.md)。

官方 niri 配置说明：[环境与其他选项](https://github.com/niri-wm/niri/wiki/Configuration%3A-Miscellaneous)。


## 登录动画与蓝牙

正常 Niri 登录时，先显示用户名书写动画，再加载完整 Clavis；面板真实就绪后淡出。
这是独立的短生命周期 `clavis-startup.service`，不是新的登录 session；普通面板刷新不会重新播放。
首次画面或主面板失败时均有超时回退，不用虚假百分比表示加载。
更改显示名字可给该用户 unit 添加 `Environment=CLAVIS_STARTUP_NAME=你的名字`，字体与颜色入口是源码
`Modules/Startup/StartupCover.qml`。停用可屏蔽该用户 unit；登录继续正常进行。

蓝牙若显示 rfkill 阻止，现在仍可点击开启：仅在你请求开启时解除蓝牙软锁，再启用适配器。
不会在每次登录时强行打开蓝牙，不影响 Wi-Fi，也不绕过硬件开关。

### 视频壁纸边缘绿线

已确认本机 Waywallen 0.3.3 的 Vulkan 解码路径会在屏幕最右四列产生绿线。
当前通过 Waywallen 的视频设置将硬件解码改为 `none`（软件兼容模式），保留原视频、分辨率、帧率及各屏选择。
代价是 CPU 开销可能增加；以后驱动或渲染器修复后可在 Waywallen 设置里改回 `auto`。


## 双屏扩展排列

两个显示器的输出定义现由可编辑片段管理，不再因位于 personal-base 而只读。
**设置 → 常规 → 显示器 → 配置** 可拖动矩形，调整左右／上下位置，再通过预览保留。
当前外接在左、内置在右的实际布局及刷新率未被改变。迁移、备份与旧机器更新见
[显示器只读与扩展排列](CONFIGURATION.md#显示器只读与扩展排列)。


## 音量滚轮、Emoji 与锁屏输入（2026-10-22）

- **音量**：拱石音量浮层、设备和应用音量滑块支持滚轮。向上增加、向下减少；
  浮层每次调整 5%，Qt 滑块沿用其步长；浮层从静音开始调整会解除静音。
  已验证真实滚轮事件改变数值；测试使用独立音频对象，没有改动当前音乐音量。
- **Emoji**：`Super+Period` 或 Spotlight `/emoji`。顶部图标选择全部、表情、人物、
  动物、饮食、旅行、活动、物品、符号、旗帜、肤色／发型；悬停显示名称。
  点选分类后仍可直接输入中英文关键词，切类自动选第一项，Enter 复制并关闭。
  当前目录为 Unicode Emoji 16.0 / CLDR 47 的 3,790 项，不再截断到前 80 项。
  更新目录时在源码根目录运行 `python3 tools/update-emoji-catalog.py`；这是显式联网更新，
  输入 URL、版本与 SHA-256 记录在 `assets/emoji/UPSTREAM.json`，不复制旧 Ambxst 数据。
- **锁屏**：Caelestia 与默认样式沿用原 PAM 密码认证，只更换输入组件。
  输入支持当前硬件键盘布局、Backspace、Ctrl+U 清空、Ctrl+W 删词和 Enter 提交。
  锁屏密码框不启用输入法候选／状态弹窗，也不粘贴剪贴板；桌面应用输入法设置不变。
  如密码需要 IME 组合输入，这个限制仍需评估；不要在未验证前当成已经支持。

旧日志出现 `xdg_popup must have parent before mapping` 后 Clavis 退出，导致 niri 的保护红屏。
同类 [上游输入法问题](https://github.com/AvengeMedia/DankMaterialShell/issues/2131)
支持 IME 弹窗这一排查方向；本机旧实现未在隔离环境复现，故不宣称唯一根因已证实。
已在带 QApplication／Fcitx 的隔离 niri 中验证两种样式取得安全锁、输入后进程存活，
息屏再亮屏后锁仍安全；**真实挂起／唤醒与密码认证尚待手动验收**。
测试没有读取密码、调用真实认证或令主会话睡眠，也未执行或预约关机。


### 打开文件夹的回退顺序

已按最新要求改为 **系统默认（当前 Nautilus）→ Nautilus → Thunar → Dolphin**。
后几项仅在上一命令失败或缺失时回退；不改普通文件、网页或废纸篓关联。
设置默认应用即可换入口，不用再修改源码。详细说明见 [Nautilus 配置教程](NAUTILUS.md)。


## 壁纸配色、自定义颜色与模板查看（2026-10-22）

在 **设置 → 主题 → matugen 配色方案** 中：

1. 选择“强调色”或“壁纸”。壁纸来源只读取当前所选渲染器；后台仍运行的 Waywallen 不再覆盖静态壁纸取色。
2. Waywallen 跟随实时壁纸 ID 自动更新，优先预览图，缺预览的视频本地取帧并缓存；没有可读图像的场景明确提示并保留旧色。
3. 强调色提供紫、粉、青、绿、橙、红六个预设；也可填 `#RRGGBB`，点击“应用”。
4. 填颜色名称，点“保存颜色”；点击已保存色应用，垃圾桶只删除该保存项，不更改当前生效颜色。
   最多 32 项，名称最长 48 字符；同名（忽略大小写）更新原项。数据保存在现有 `ui-preferences.json`。
5. 保存项仅保存强调色，不包含整套 GTK／Qt 样式、壁纸、模板或全部应用配置。

强调色是算法的来源色，生成后的主色还会随方案、亮暗模式和对比度变化，未必等于输入的十六进制。
切换静态壁纸／调色板时，若仍选择强调色来源，不会再悄悄替换你的强调色。

| 方案 | 意义 |
|---|---|
| Tonal spot | 柔和强调色、均衡对比 |
| Vibrant | 更强色度，强调色更鲜明 |
| Content | 尽量保留来源色，配合相近强调色 |
| Expressive | 偏移强调色色相，风格更活泼 |
| Fidelity | 保留来源色特征，搭配互补强调色 |
| Fruit salad | 偏移主色与次色色相，形成多彩组合 |
| Monochrome | 黑白灰，不保留彩度 |
| Neutral | 中性为主、较淡的强调色 |
| Rainbow | 多彩强调色、无染色的中性背景 |

各按钮悬停可查看说明，当前方案解释也显示在下方。
算法参考 [Material 配色文档](https://github.com/material-foundation/material-color-utilities/blob/main/dev_guide/creating_color_scheme.md)。

### 模板源码与教程

**设置 → 高级 → Matugen 模板 → 代码图标**：查看输入路径、输出路径、生成后命令和实际模板全文。
内容只读、可选中；不运行生成、不执行命令。仅读取可读、非目录、最多 256 KiB 的模板。
读取失败保留明确错误，不显示旧模板内容。用户模板仍可用文件夹图标定位，在外部编辑器修改后重新查看。
“模板教程”打开随源码安装的 [本地模板教程](../.local/src/clavis/docs/matugen-templates.html)。

Kitty 保留已有受保护的主题选择器回退。Yazi 采用 **独立配置 overlay**：
`~/.config/niri-clavis/settings/yazi/`，个人 `~/.config/yazi` 与其中的 dotfiles 不修改。
启用 Yazi 模板后指向 `~/.local/share/clavis/profiles/default/generated/yazi/theme.toml`；
关闭后恢复指向个人主题。其他配置、插件等继续链接到原目录；选择器被手改时保留并报错。
`YAZI_CONFIG_HOME` 已接入 profile 和 Shell，**新终端／下次登录**使用该 overlay；已有终端需重新打开。
不会为验证改变你当前 Kitty/Yazi 模板开关，也不把过去无备份的其他模板覆盖宣称为可恢复。

GTK 模板写入 `~/.config/gtk-4.0/gtk.css`，Nautilus 等 GTK4／libadwaita 应用会跟随 Matugen 配色。
GTK4 只在应用启动时读取用户 CSS，切换主题后需重新打开 Nautilus；启用前先备份原 `gtk.css`。

`icons` 模板维护继承 Tela 系列的 `Tela-Matugen` 图标主题 overlay，只替换文件夹图标的强调色；
当前图标主题不是 Tela 系列时跳过。切换配色后同样需要重新打开 Nautilus，关闭模板会恢复原 Tela 主题。

### 原生最小化时显示 Dock

启用 Dock 自动隐藏时，应用发出原生最小化请求，会让其所在屏幕的 Dock 显示约 2.5 秒。
鼠标移入可继续点击恢复，离开后仍沿用原有隐藏延迟；关闭自动隐藏时 Dock 本来就显示。
不改变焦点、不移动到隐藏工作区。按你后续澄清，最小化窗口保留在 Dock，点击 Dock 恢复；已清空此前两项自动折叠选择。
不需要先点 Dock 才能最小化。应用没有最小化按钮时才使用 Dock 的最小化入口。


## 可选：指定程序最小化后折叠（当前关闭）

入口：**设置 → 常规 → 程序坞 → 折叠最小化程序**。也可搜索“折叠最小化程序”直达。

1. 先打开目标程序，再打开对应开关；选过的程序退出后仍留在设置列表，可随时关闭策略。
2. 正常最小化后，窗口进入状态栏或拱心石的托盘折叠弹层，点击箭头可看到窗口标题；点击标题恢复该窗口。
3. 同一程序多个窗口分开列出。只有最小化的窗口被折叠，其余仍在 Dock；未选择的程序维持原行为。
4. 当选中程序的所有窗口都最小化，Dock 暂时隐藏该程序的槽位；**不会删除固定项**，恢复窗口或关闭全部窗口后固定入口重新出现。
5. 关闭状态栏／移除托盘组件／该输出消失后，只要没有任何可见托盘，所有窗口自动回到 Dock，避免丢失恢复入口。
6. 程序没有系统托盘图标也能用，只需提供稳定 app-id；无法识别身份的 `unknown` 窗口不提供持久化选择。
7. 选择项保存在现有 `settings/dock.json` 的可选 `foldMinimizedApps` 字段，最多 128 个；旧配置无需手动迁移，默认不折叠任何程序。

这是真实 niri-edge 最小化窗口的恢复列表，不是移动到 scratch 工作区、不结束或暂停程序，
也不伪造应用自身的托盘菜单。原有“托盘图标常驻／折叠”选择继续独立生效。
这是额外可选功能，按你澄清的需求已关闭自动折叠；不删除 Dock 固定项。

## 窗口亮度、模糊与焦点微晕

设置 → 常规 → 特效 → **窗口聚焦**：背景模糊、未聚焦亮度降低（0–40%）、壁纸／自定义微晕颜色。
默认降低 8%；新的 Niri 只降低窗口 RGB，不降低 alpha，所以透明背景与模糊保留。
亮度降低和原生单 Super 需下次登录；微晕与模糊可在当前会话使用。
壁纸微晕通过独立 Matugen dry-run 取色，不运行其他模板或 hooks；无预览时保留上次颜色。
托管规则位于 `clavis/window-appearance.kdl`；个人最终覆盖仍写 `local.kdl`，手改托管规则会被保护。

## 显示器复制／投影

设置 → 常规 → 显示器 → 配置 → **镜像／投影**，选来源屏幕与目标屏幕，点“开始投影”。
使用私有安装的 [wl-mirror](https://github.com/Ferdi265/wl-mirror)，整屏复制并适配目标分辨率；
不把输出坐标重叠冒充镜像，也不改已有扩展布局。停止、拔屏、锁屏会结束本次投影，不自动开机共享。
投影包含来源屏幕的全部内容，打开隐私内容前请停止。
已获准实测 eDP-1 → HDMI-A-1 约 5 秒，真实客户端位于外接屏，停止后布局不变，未保存截图。

## 默认锁屏与壁纸切回

默认锁屏有静态背景兜底：Waywallen 预览 → Clavis 静态背景 → 个人 banner。
没有静态预览的视频仍保留原动态配置；锁屏使用兜底图而不是黑色视频表面。
图片加载不再阻塞认证 UI，快照超过 1.2 秒未就绪也显示锁屏内容。
这不改变 PAM；真实挂起→唤醒→密码登录仍按你要求稍后验收。
Waywallen 切回会请求 Resume；启动失败可重试，元数据读取失败不会把已安装后端误判为缺失。
刷新后真实 Shell 的 Quickshell → Waywallen 往返已验证，返回原配置且其他偏好不变，无截图。

## 本次验证与备份

新增源码与 profile 修改均先备份／比对，不覆盖并发个人更改。备份根目录：
`/home/nan0in/.local/state/clavis/remaining-20261022-185240/`。
原 niri 二进制／清单、GTK 设置、Dock 自动折叠选择等在其 `deployment-before/`，
源码原件在 `before/`，文档原件在 `docs-before/`。
本次配置 136 个有效按键无重复；原生输入 6 项、原生配置 24 项测试通过，投影及窗口 alpha 像素验证通过。
12 个改动 QML 检查通过，**62 条 advisory warnings**：
`/home/nan0in/.local/state/clavis/remaining-20261022-185240/qml-lint-late.log`。
ShellCheck 未安装，该阶段保留为阻断；独立 Shell/Python 语法、功能及现有契约测试通过，不宣称全量零警告。
**真实挂起／密码验收之前不执行或预约关机。**

## QQ／XWayland 窗口自己的最小化按钮

此前只验证原生 Wayland 客户端，漏掉了 QQ：本机 QQ 正在 XWayland 运行，
xwayland-satellite 0.8.3 未处理 `WM_CHANGE_STATE / IconicState`，所以窗口自己的最小化请求未到 Niri。
已补 `clavis-x11-minimize.service`：旁路监听该窗口请求，按 **唯一的 WM_CLASS＋标题＋satellite 归属**
匹配 Niri 窗口后调用原生最小化；不抢窗口管理器、不监听键盘、不修改 QQ 登录数据或主题。
重复／无法唯一匹配的请求不操作其他窗口；原生 Wayland 窗口保持原路径。

**当前会话已生效，不用重启 QQ 或 Niri。** 下次正常 Niri 登录也会启动该服务。
点 QQ 自身的“—”最小化后，QQ 保留在 Dock；Dock 自动隐藏时移到屏幕边缘展开，点图标恢复。
不会收进托盘折叠区，也不把窗口关闭到后台。QQ 的“关闭窗口到托盘”是另一个应用设置，本次未改。

已对当前 QQ 的同一窗口发送与最小化按钮相同的 ICCCM 请求：Niri 状态变为最小化，
实际 Dock 模型保留 `app:qq` 一项，随后经 Dock 的恢复接口还原同一窗口。
QQ、Clavis 与 Niri 均未重启；个人 Dock 配置未变，未保存截图。

排障：`systemctl --user status clavis-x11-minimize.service`，
日志 `journalctl --user -u clavis-x11-minimize.service -n 30 --no-pager`。
源码为 `wm/clavis/.local/src/clavis/scripts/system/x11_minimize.py`，安装／卸载只管理自有 unit 链接。
上游对应路径：[v0.8.3 X11 client message 处理](https://github.com/Supreeeme/xwayland-satellite/blob/v0.8.3/src/xstate/mod.rs#L523)。

## Waywallen 自动轮换时跟随配色（2026-10-23）

设置 → 主题 → 配色来源选择 **壁纸**，桌面壁纸管理器选择 **Waywallen**。
已有的强调色、方案与外部模板开关保留，本次没有替你更改这些偏好。

此前只读数据库 `preview_path`，但本机一些视频项目根本没有下载 preview.gif，数据库值也为空；
这会在轮换到对应项目时一直“等待预览”。现在每 5 秒读取 Waywallen 实时 D-Bus 壁纸 ID，
优先于可能滞后的磁盘配置，再查当前项目的颜色源：

1. 数据库预览、project.json 声明的本地预览、常用本地 preview 图片；
2. 静态壁纸图像本身；
3. 缺预览的视频用已安装 FFmpeg 本地取一帧，标准化为不超过 512×512 的 PNG。

缓存位于 `~/.cache/clavis/waywallen-previews/`，最多保留 48 个生成的 PNG。
ID、源路径、文件时间与大小组成缓存标识，切换项目或图片内容更新会产生新颜色源，
避免路径重复而漏掉更新。每次轮询不会重新解码同一视频；失败会短暂退避。
只读取本地壁纸文件，不录桌面、不录声音、不上传图片，不改 Waywallen 数据库／项目文件。

**确实没有可读图像的场景包**（例如仅 scene.pkg 且预览文件缺失），保持上一次有效配色，
并显示“此壁纸没有可读取的预览，保留上一次配色”，不再无限等待或误取后台的静态壁纸颜色。
这不是逐帧动态取色；配色随“壁纸项目切换”更新，不跟着视频每一帧闪动。

验证：隔离真实 QML＋Matugen 中模拟自动轮换蓝色视频→红色视频，配色文件实际变化；
当前真实壁纸生成的主色与独立 Matugen 计算一致。真实缺预览的视频亦已成功取帧并生成主色。
Qt 翻译目录编译、已有 i18n_manager_tests 1/1、scoped check 均通过；
2 个 QML 文件有 **1 条 advisory warning**，日志：
`/home/nan0in/.local/state/clavis/waywallen-colors-20261023-010908/quality/qml-lint.log`。
仅刷新 Clavis，Niri 和已打开应用未重启；配置和修复前源码备份位于 `/home/nan0in/.local/state/clavis/waywallen-colors-20261023-010908/before/`。
