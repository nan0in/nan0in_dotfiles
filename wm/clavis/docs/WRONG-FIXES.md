# wrong.md 逐项调整

> 按轮次保留历史记录；旧段落中的“待实现”不是当前状态。以末尾“最新完成”和
> [当前指南](START-HERE.md) 为准。


原始需求保留在 `wm/clavis/wrong.md`，按你最新要求仅为已完成项加删除线；未完成和部分完成项继续保留。下面区分已实施内容与平台差异。

| 原问题 | 本次调整 / 使用方法 |
|---|---|
| 找不到状态栏开关 | 新增 `Super+Ctrl+B` 直达“常规 → 栏”；打开“显示栏”。快捷键通过注册的设置路由定位到子页面，不再误回账户首页 |
| 栏在底部，展开仍向下 | **托盘折叠弹层待实际复测，wrong.md 不划掉本项。** 先前修复的是 Spotlight 依据栏位置决定方向：底部结果在搜索框上方，顶部在下方；工具／计算器跟随同样方向 |
| niri 配置目录不可写 | 将整个 profile 的软链接改为真实目录；保留上游符号链接写保护，未改权限绕过检查。UI 的 `clavis/*.kdl` 在真实运行目录中写入 |
| 顶部拱石盖住右边栏 | 同一水平边为拱石预留中间区域，左右模块按实际可用宽度缩放，窄屏也不穿过中间时钟。展开的拱石内容仍是临时覆盖层 |
| Super 无差别弹出搜索 | 移除原 `Mod+super_L` 绑定。单按 Super 不做动作；`Super+Space` 搜索，组合键不再预先打开搜索 |
| Qt / GTK 主题未加载 | 已按最新反馈改为 Material Dracula；Dolphin 单独指定配色及深色图标，保留全局图标、字体和其他个人设置。GTK 继续 `Dracula-alt-style`，原 KvDark 文件及回滚备份保留 |
| 选择应用收进折叠栏 | 在“常规 → 栏 → 常驻托盘图标”逐项选择；中键托盘图标快速切换。窗口的“最小化到托盘”开关仍在各应用中设置。没有托盘能力的窗口不伪装成托盘图标 |
| 完整配置文档、niri 指引 | 新增 [从零到日常使用](START-HERE.md) 和 [本地网页手册](START-HERE.html)，涵盖安装、列／工作区、快捷键、默认应用、网络、主题、定制、排障与回退 |
| 中文顶部日期字体 | 日期单独采用已安装的 Noto Sans CJK SC，缺失时回退 UI 字体；保留霞鹜文楷等个人字体选择和 Google Sans Flex 数字时钟 |
| 网络和连接功能 | 新增 `Super+Ctrl+N` 直达原生网络页；保留 nm-applet／blueman，整理 nm-connection-editor、nmtui、Wi-Fi／蓝牙入口与只读诊断，不重启网络、不改连接配置 |
| 打开文件夹跟随设置 | `Super+E` 从写死 Thunar 改为 GIO 默认目录处理程序；与设置中心的“默认应用 → 文件管理器”一致。当前 Dolphin 的 MIME 选择原样保留 |

## wm/ 整理与配置保护

- 源码包为 `wm/clavis/`、`wm/ambxst/`，稳定的用户链接重新指向新目录。
- `install.sh stow ambxst` 继续工作；GNU Stow 模拟检查确认目标归属。
- `config/.config/hypr/` 与 `config/.config/ambxst/` 不移动、不覆盖；它们仍由原 config 包管理。
- Clavis 安装使用模板／运行目录分离；哈希记录防止更新覆盖手改文件。
- `local.kdl`、UI 片段、settings 数据后续安装始终保留；卸载保留真实运行配置。
- 旧 CMake build 保存于迁移备份，用新源码路径重新构建，未篡改生成物中的旧路径。
- 不新增 PATH 启动二进制，不新增登录 session，不重启当前 niri 或用户应用。

## 验证范围

原生模块重新构建，27 项现有 CTest 全部通过；niri validate、systemd unit 检查、Shell/Python 语法检查通过。
安装器临时 HOME 验证了首次部署、模板更新、个人编辑保留、符号链接父目录保护、卸载保留和冲突预检。
原 niri/Hyprland 26 个受保护配置哈希一致。

独立 D-Bus／嵌套 niri 中检查上下两种 Spotlight、窄屏顶栏和设置页面；嵌套环境的 PipeWire／portal
警告不等同主会话故障。验证不对真实网络执行连接、断连或密码修改，也不执行锁屏／挂起。
Ambxst 原有 541 个跟踪文件迁移前后内容一致。Qt 样式探针加载 kvantum；GTK3 使用 Dracula 时实际背景样式与未指定主题的默认值不同。

QML lint 为 advisory 模式，本次 8 个改动 QML 文件共 89 条 advisory warning。
日志：`~/.local/state/clavis/wm-validation-20261021-213547/qml-check/qml-lint.log`。
最后一次嵌套 UI 验证没有 Binding loop / ReferenceError / TypeError；主会话刷新后加载成功。
本机未安装 ShellCheck；Shell 只做 `bash -n`，未为了验证安装系统包。
具体日志位于 `~/.local/state/clavis/wm-validation-*/`。

## 后续：监控横线与搜索位置

- CPU / 内存 / 温度横线：确认私有 key-cli wheel 缺少原生 `key-sysmon`，补装同版本采样器；
  `deps` 纳入原生构建，另有 `repair-sysmon` 单项修复命令。采集逻辑仍由 key-cli 负责。
- 搜索位置：新增设置 → 通用 → Spotlight → 弹出位置；跟随状态栏、顶部、居中、底部，
  即时生效并持久化，默认保持当前跟随状态栏逻辑。详见 [定制说明](CONFIGURATION.md#搜索弹出位置)。

## 后续：Dracula、Waywallen 与截图编辑

按用户选择统一 Dracula，新增强调色／壁纸配色来源、Waywallen 预览管理入口，
以及 niri 捕获 → Spectacle 编辑与高级截图菜单。原 Kvantum、GTK、Waywallen 和 Satty 配置保留。
详见 [桌面集成说明](DESKTOP-INTEGRATION.md)。

## 后续：快捷键冲突与设置编辑

- 29 组旧层重复定义已按生效优先级合并，窗口／工作区／Shell 绑定统一进 UI 可写的 `clavis/binds.kdl`。
- 保留 Ambxst 锁屏、列布局与方向键习惯；新增 `Super+Ctrl+V` Dashboard 侧栏切换。
- 修正一条用户界面写入的无效 `sidebar` 动作，保留其 `Ctrl+Super+A` 按键作为额外入口。
- 快捷键保存不再发布 niri 校验失败的配置；同一片段的物理键别名重复也会拒绝。
- 编辑／删除 UI 绑定后不再露出旧层快捷键；安装器不会填回用户删除的绑定。
- 原 `~/.config/niri/`、Hyprland 与 Ambxst 个人配置、Clavis 设置 JSON 不覆盖。
- 剪贴板设置读取、rfkill、托盘实际展开复测、原生最小化、Spotlight Emoji、剩余 Ambxst 工具与焦点微晕仍待处理。

迁移和审查命令见 [配置说明](CONFIGURATION.md#快捷键冲突与旧版本迁移)。

本轮验证：当前有效 141 个组合键（包含滚轮），重复定义 0，niri validate 通过。
复用的 40 项配置集成测试全部通过；真实 profile 的临时副本验证了改键、删除后无旧绑定恢复、
无效动作和大小写别名冲突拒绝保存，迁移重复执行不改文件。
临时 HOME 验证首次安装和再次安装保留删除的快捷键、个人覆盖与设置。
174 个原 niri/Hyprland/Ambxst 文件哈希、13 个非绑定 UI 片段/设置文件保持一致。
本轮只有 Python/配置/文档改动，执行 scoped check.sh、Python 语法及 bash -n，未新增 QML 检查或重启。
niri PID 仍为 1796，配置已被现有进程自动重载。
日志：`~/.local/state/clavis/bindings-fix-20261021-225210/`。

## 后续：按 wrong.md 最新补充继续

- 取消 Super+Ctrl+V，并移除另外五个冗余侧栏/设置/电源/壁纸入口；有效 135 个组合键、重复 0。
  前面关于新增该键的记录是历史状态，现以本节和 KEYBINDINGS.md 为准。
- 剪贴板改用独立配置根，避开已有个人文件；设置页的 500 → 550 → 500 实际读写已验证。
- Dolphin 使用 Material Dracula 控件、明确的 KDE 深色配色与仅对 Dolphin 生效的清晰图标；
  在独立 niri 和临时 Dolphin 配置中验证，不关闭真实应用，不改全局 KDE 设置。
- 底部托盘弹层的坐标错误已复现并修复，实际验证向上展开及点击外部关闭。
- 右侧绿线已确认在壁纸显示边缘，尚未确认渲染根因，wrong.md 保持未划掉。
- “打开状态栏”用户再次标为未完成，保留该状态并确认具体指常驻栏还是侧栏。

当前外观、剪贴板路径及剩余绿线诊断见 [桌面集成说明](DESKTOP-INTEGRATION.md)。

本轮验证：135 个组合键无重复、niri validate、systemd unit 校验、Python 语法和外观应用/回退/冲突保护检查通过。
实际设置页读写已测试；独立 Dolphin 配置和 niri 中检查 Material Dracula 与图标对比，底栏托盘实际向上展开且能外部点击关闭。
顶部弹层的本轮独立视觉检查被中断，不把它写成已验证结果；方向定位已改用原生锚定。
QML scoped check 完成，45 条 advisory warnings，日志位于
`~/.local/state/clavis/continue-fixes-20261021-231815/qml-check/qml-lint.log`。
Clavis 和 clipboard watcher 已按先前确认刷新，正常加载无 ReferenceError / TypeError；niri PID 1796 不变。
174 个原 niri/Hyprland/Ambxst 配置文件哈希一致；现有同名个人文件的 inode/时间/权限不变，未读取其内容。
用户同时修改的 ui-preferences.json 已保留，未重置。


## 后续：Dock 不占位与单 Super 的边界

- Dock 改为覆盖层，无论自动隐藏开关或所在边缘，都不向 niri 申请应用工作区。
  独立 niri 的左侧、非自动隐藏 Dock 实测：945 宽输出上，最大化应用从 867 恢复到 945；
  实际客户区像素范围也覆盖完整输出宽度。未操作真实用户窗口。
- `Super+M` 保持列最大化，`Super+F` 保持窗口全屏，没有为修 Dock 偷换按键语义。
- 用户已确认单独轻按 Super 松开后搜索、组合键不触发；这项尚未完成，wrong.md 不划掉。
  当前 niri 不接受裸 `Mod`；旧 `Super+Super_L` 又会在按下时误触发，因此仍保留 `Super+Space`。
- 设置页对不支持的修饰键绑定、已占用按键分别给出中英繁体错误提示，翻译库已编译，现有 i18n 测试 1/1 通过。
- 上游原生 release PR 未合并，且与最小化分支存在合并冲突；没有盲目应用，等待私有构建方案确认。
- 新增的用户名加载动画需求保留为待处理；没有以固定延时或虚假进度把它标为完成。

本轮 scoped QML 检查完成，**9 条 advisory warnings**；当前有效 135 个快捷键、重复 0、niri 校验通过。
日志：`~/.local/state/clavis/super-tap-dock-20261022-000253/qml-check/qml-lint.log`。
几何验证：同目录 `geometry-result.json`、`controller-final.log`。
当前主 niri PID 2110 保持不变。检查时锁屏处于 secure 状态，因此暂未重启 Clavis，避免中断锁屏；
上述界面改动将在解锁后刷新 Clavis 或下次登录时加载，个人设置和已打开应用保持不变。


## 后续：实际登录、最小化与剩余项验收

- 本次登录真实使用私有 niri-edge；系统 niri 保留，正常 Niri 登录入口不变。
- Clavis 最小化／恢复原先同步等待回复会阻塞事件循环，出现“窗口已最小化但返回失败”；
  已改为异步请求、由窗口事件确认状态，独立真实窗口及现有 native tests 均通过。
- Spotlight Emoji 完成中英关键词、显示、选择复制和关闭的实际验证；原 Super+Period 入口已接入。
- 聚焦窗口紫色微晕完成实际画面验证。
- 蓝牙从实际 blocked/off 状态，通过 Clavis 开启逻辑验证到 unblocked/on；不自动扫描、连接设备或修改 Wi-Fi。
- 用户名动画采用独立轻量进程，首帧先于完整 Shell，实际 ready 后退出；冷启动已验证，正常登录脚本与 unit 已部署。
- Waywallen 已进入同一后端下拉；切换、保存、重新加载和原生壁纸偏好保留均已验证，真实配置现选择 Waywallen。
- 右侧绿线完成 Vulkan / 软件交替复现与消除，最终仅修改视频 hwdec=none；CPU 开销权衡见桌面集成文档。

既有 27 项 CTest 的结果均已核验；release fixture 在隔离 Git 环境下单独复验通过，
避免本地 scoped-check 的临时 Git 变量干扰其自建仓库。更新的翻译已编译，i18n test 通过。
QML 最新 scoped check 有 **233 条 advisory warnings**，并非零警告；日志：
`~/.local/state/clavis/completion-20261022-002048/source-check-final/qml-lint.log`。
详细的窗口、Emoji、蓝牙、动画和绿线结果保存在同一 state 目录；只对已验证完成项划删除线。
仍未完成的单 Super、Ambxst 剩余工具、折叠策略与状态栏含义保留在 wrong.md。
当前尚未达到“全部确凿完成”条件，未执行或预约关机。


### 新增：双屏输出编辑

将 personal-base 中两条输出定义原样迁入 `clavis/outputs.kdl`；UI 模型中两屏均为 editable=true。
独立草稿验证外接移到内置右边有效，未调用硬件应用；迁移、草稿检查前后真实输出 JSON 完全相同。
临时 profile 验证迁移幂等，并验证“迁移前已有个人修改 → 再安装”仍保留该修改。
镜像或单屏预设所需范围待确认，不用重叠输出位置冒充镜像。


## 2026-10-22 后续：工具迁移与通知恢复

拱石补齐 9 个入口，原 5 个工具保留；网格采用横向 7×2、侧边 2×7，
方向键和 Enter 与布局一致。独立 niri 中实际绘制验证，OCR／二维码以合成画面验证复制，
取消保留原剪贴板。默认文件管理器、带空格目录、设置中的录屏目录已用隔离入口验证。
qalc 单位换算和 Kitty 窗口实际启动已验证。镜子独立入口的中文标题和关闭已验证；
未启动真实摄像头，故 wrong.md 的工具父项仍保留未完成状态。

通知的根因还包含超时单位：当前 Quickshell 0.3.2 实际给出 D-Bus 原始毫秒，
旧代码按秒又乘 1000。现保留原始毫秒，并为临时展示增加独立 7 秒上限；
不通过 dismiss/expire 伪造收起。真实 D-Bus 合成测试确认：
1000ms 消息按时到期，0／60000ms 消息收起后仍存活，历史与未读数保留。
独立 compositor 画面确认拱石从提示卡恢复原形。

原生包入口变动完成构建及现有 **27/27 CTest**；首次检查因临时 Git 环境干扰
release_contracts 留有失败记录，后续将该环境从 CTest 隔离后整组通过，未修改测试迎合环境。
三语言目录新增 19 条消息，编译为 2718 条（3 条既有 unfinished 保留）。

本轮最终 scoped check 检查 **5 个 QML 文件，10 条 advisory warnings**，不是全树零警告；
日志 `/home/nan0in/.local/state/clavis/tools-migration-20261022-123549/completed-check-details/qml-lint.log`。
功能结果、截图和原文件备份在该 state 目录内。镜像摄像头实现参考
[Qt Camera](https://doc.qt.io/qt-6/qml-qtmultimedia-camera.html)、
[VideoOutput](https://doc.qt.io/qt-6/qml-qtmultimedia-videooutput.html)；
超时单位以[当前 Quickshell 实现](https://github.com/quickshell-mirror/quickshell/blob/v0.3.2/src/services/notifications/notification.cpp)及实际 D-Bus 值为准，
而不是其仍标秒的生成文档。

本轮补充说明截图编辑器为 Spectacle，Satty 保留备用；复制投影需求现已明确，
仍待实现与验证。单 Super、任意最小化程序折叠、镜子实景等未完成项仍保持打开，
未执行或预约关机。

最终检查完成后，检测到当前仍打开 Clavis 自身设置窗口；为保留可能的编辑草稿，未额外执行 systemd 重启。源码已由现有热重载机制加载，真实 niri PID 2119 不变；关闭设置窗口后可再做一次干净刷新。


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

### 本轮验证记录

验证记录：`/home/nan0in/.local/state/clavis/resume-fixes-20261022-134512`。
- 带 QApplication / Fcitx 的输入组件功能测试通过；拱石、设备、应用滑块均收到实际滚轮事件。
- Emoji 的 10 个分组数量相加为 3,790；实际鼠标切类、随后键盘输入、混合肤色查找、国旗复制与隐藏通过。
- 两种锁屏取得安全锁、合成输入后存活、息屏／亮屏后仍保持安全。未调用 PAM，不等于真实睡眠解锁验收。
- scoped check：11 个 QML 文件及更新脚本通过；**189 条 QML advisory warning**，不是零警告。
  日志：`/home/nan0in/.local/state/clavis/resume-fixes-20261022-134512/scoped-check-details/qml-lint.log`。
- 三份翻译已编译；现有 `i18n_manager_tests` 1/1 通过。未改 native 接口，不重复全量 CTest。
- 源码发布前逐文件比对原始副本，未检测到并发覆盖冲突；未改个人设置。Clavis 已单独刷新，niri 进程未重启。

测试中遇到嵌套窗口不可见时的帧等待；显示测试窗口后完成验证。
早期失败日志保留：另有测试脚本误将最终 `hidden` 阶段写成 `closed`，已更正后重测；不属于产品缺陷。


### 打开文件夹的回退顺序

`Super+E`、拱石截图／录屏文件夹、Dock／Shell 的本地文件夹入口统一为：
**设置 → 默认应用 → 文件管理器**所选应用 → **Thunar** → **Dolphin**。
默认应用页沿用 `inode/directory` MIME 选择，不另存一套互相冲突的配置。
仅在处理器缺失或启动命令报错时尝试下一项；应用启动后自行出错不属于可检测的回退条件。
当前仍选择 Dolphin，没有为了实现顺序修改默认应用、字体、图标、文件排序或其他个人设置。
普通文件仍使用对应类型的默认应用，网页和废纸篓的处理保持原样。

回退 helper 的七个分支、Unicode／空格参数及已有工具路由通过；原生文件夹识别 → QML 路由的独立会话验证通过，未实际启动测试文件管理器。
仅替换 Super+E 的动作，其他有效按键未修改；活动 niri 配置校验通过，niri PID 2064 未变。
补充检查只覆盖 1 个 QML 与脚本：通过，**1 条 QML advisory warning**，日志：
`/home/nan0in/.local/state/clavis/resume-fixes-20261022-134512/folder-url-check-details/qml-lint.log`。
补充完成后已再次单独刷新 Clavis；本轮最终状态另见 `/home/nan0in/.local/state/clavis/resume-fixes-20261022-134512/handoff.json`。


## 壁纸配色、自定义颜色与模板查看（2026-10-22）

在 **设置 → 主题 → matugen 配色方案** 中：

1. 选择“强调色”或“壁纸”。壁纸来源只读取当前所选渲染器；后台仍运行的 Waywallen 不再覆盖静态壁纸取色。
2. Waywallen 使用预览图提取颜色，不逐帧采样视频；等待预览时会明确显示状态，预览到达、换壁纸后自动更新。
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

**关闭模板不是通用撤销操作。** Kitty 保留已有的受保护选择器回退；Yazi 接入仍待确认，
因为 `~/.config/yazi` 链接到 dotfiles，直接替换入口会影响个人仓库文件。
本轮没有修改 Yazi 主题、Kitty 原主题或默认应用，也不把过去无备份的覆盖宣称为可恢复。

### 原生最小化时显示 Dock

启用 Dock 自动隐藏时，应用发出原生最小化请求，会让其所在屏幕的 Dock 显示约 2.5 秒。
鼠标移入可继续点击恢复，离开后仍沿用原有隐藏延迟；关闭自动隐藏时 Dock 本来就显示。
不改变焦点、不移动到隐藏工作区，也不等于“任意最小化程序收进托盘折叠栏”；后者仍是待办。

### 本轮验证边界

旧行为已在独立 HOME／设置／niri 中复现：静态后端误取 Waywallen 预览，以及 Waywallen 无预览时误用旧静态文件。
修复后真实 Matugen 4.2.0 的九种方案均生成成功；预览延迟、外部切换、强调色隔离、保存／同名更新／删除及重启恢复通过。
实际鼠标点击了预设、保存项、保存及删除按钮；修正了检查中暴露的 delegate 上下文问题，界面截图复查通过。
原生 Qt 客户端发出 `xdg_toplevel.set_minimized` 请求后，Dock 展开、超时收回和恢复窗口通过。
模板查看器对实际正文、空格／百分号／井号路径、缺失文件及大小上限通过；确认没有生成输出或执行 post-hook。

两批 scoped check 均通过，QML advisory warning 分别为 **29 条（6 文件）**、**22 条（4 文件）**，不是零警告：
- `/home/nan0in/.local/state/clavis/theme-fixes-20261022-174306/final-check-details/qml-lint.log`
- `/home/nan0in/.local/state/clavis/theme-fixes-20261022-174306/next-final-check-details/qml-lint.log`

三份翻译已编译，现有 `i18n_manager_tests` 1/1 通过；两批现有搜索目录协议检查通过。未改 native 接口，不重复全量 CTest。
测试只使用独立配置及合成图像；真实挂起唤醒仍待用户验收，Yazi 接入选择仍待回复，未执行或预约关机。


## 2026-10-22 后续：按程序折叠原生最小化窗口

已补齐无托盘程序的选择策略：常规 → 程序坞 → 折叠最小化程序；设置搜索支持直达。
折叠列表复用托盘弹层，顶部向下／底部向上；每个窗口以原生 restore 请求恢复，
未最小化窗口继续显示在 Dock，固定项只临时隐藏、不删除。没有可见托盘时回退 Dock。
个人 dock.json 未替换、未预选任何程序，旧格式默认空列表，现有选项和固定项保留。

隔离真实 niri-edge 验证：同程序混合窗口、多个折叠窗口、固定槽位、非选中程序、
无 desktop 文件、托盘关闭回退、开关撤销、配置重载；真实点击设置开关、顶部列表恢复和外部点击关闭通过。
顶部／底部弹层与设置页实际绘制已查看。原生最小化本身沿用已验证实现，不改 compositor。
复用 DockModel 现有测试并以独立临时样本补充配置和分流行为验证，合计 19 passed；
三语言目录编译通过，现有 i18n_manager_tests 1/1 通过。
本次 scoped check 的 3 个 QML 文件有 37 条 advisory warnings，并非零警告；日志：
`/home/nan0in/.local/state/clavis/folding-20261022-182237/final-check-details/qml-lint.log`。

真实挂起／密码验收、Yazi 接入选择、单 Super 原生支持、显示复制投影、
未聚焦亮度／微晕设置、GTK／Qt 控制及 Thunar Material 仍未在本轮完成；不关机。


## 最新完成：原生补丁、外观、投影与后续澄清（2026-10-22）

本节覆盖上文历史记录中的旧“待实现”状态；当前使用说明统一见 START-HERE.md／HTML。

- 私有原生 Niri：单 Super 松开、组合取消，客户端按下／松开完整；RGB-only dim 保持透明度。
  补丁、可重复构建与 SHA 清单已接入，下次正常登录生效，无 session 包装器。
- 窗口设置：模糊、未聚焦亮度、壁纸／自定义微晕，最后个人 local.kdl 仍优先。
- Thunar Material Dracula GTK3；主题页提供 GTK3、Qt6、图标、Kvantum 及描述，只修改必要项，字体保持。
- 文件夹按最新需求统一 Thunar → Dolphin，**不再 MIME 默认优先**，不改全局关联。
- 截图默认恢复 Satty；Spectacle 仅手动菜单可选，个人编辑器配置不动。
- Yazi 独立 overlay 与 Matugen 启用／关闭切换，原个人配置与主题未改；新终端生效。
- 复制投影：验签后私有安装 wl-mirror；实际 eDP-1 → HDMI-A-1 约 5 秒成功，停止恢复布局，无截图。
- 原 Ambxst 11 个工具已迁移为 14 入口。真实镜子摄像头默认关闭，未擅自做摄像头实拍。
- 按最新澄清关闭两项自动折叠选择，客户端按钮最小化直接进 Dock，保留固定项。
- 默认锁屏静态背景／banner 兜底、快照超时不阻塞认证，隔离渲染已见背景与时钟。
- Waywallen 切回 Resume／失败后可重试，损坏元数据不会禁用已安装程序；隔离往返及保存通过。

验证：136 个有效按键无重复；原生输入 6 项、配置 24 项，现有 Niri Python 契约 40 项、
Matugen registry 集成、翻译目录及 i18n_manager_tests 通过。Qt/GTK 字体保护、Yazi 手改保护、
安装器连续两次、真实窗口 alpha 像素、投影与隔离设置渲染通过。
12 个 QML scoped lint 通过，**62 条 advisory warnings**：
`/home/nan0in/.local/state/clavis/remaining-20261022-185240/qml-lint-late.log`。
ShellCheck 缺失，保留阻断，不称全量检查通过；独立 Shell/Python 语法已验证。
备份在同状态目录的 before/、late-before/、deployment-before/、root-before/、docs-before/。
真实挂起→唤醒→输入密码由你稍后验收，此项不划掉；未执行或预约关机。

补充实际 GTK 后端验收：Wayland 的 GSettings、XWayland 的 XSettings 以及 settings.ini 已同步；
仅改文件被另两层覆盖的原因已实证。真实两后端返回 Clavis-Material-Dracula，原字体不变。
隔离测试涵盖图标同步与外部写入失败的文件回滚，原 GSettings 值亦留有备份。
真实 Shell 的 Quickshell → Waywallen 往返与恢复保存已通过，其他偏好不变、未截图。

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

验证日志／结果：`/home/nan0in/.local/state/clavis/qq-minimize-20261022-232045/dock-result.json`；Python 语法、systemd unit 校验、隔离安装两次及卸载检查通过。未新增 QML 或更改 native core，无新增 QML lint 范围。

## 最新文件夹策略：Nautilus（2026-10-22）

用户将默认改为 Nautilus，本段取代此前 Thunar 优先要求。
已移除仅针对目录的 niri 专用 Dolphin 覆盖、设定系统默认 Nautilus，统一目录路由回归 GIO 默认。
回退为 Nautilus → Thunar → Dolphin；其他 MIME 关联、Nautilus 偏好与旧管理器保留。
实际 Super+E 动作打开 Nautilus；五个独立命令成功／失败分支及 Unicode／空格参数通过。
无 QML／native 改动，不重启桌面。[配置教程](NAUTILUS.md)。备份：`/home/nan0in/.local/state/clavis/nautilus-20261022-233534/`。

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
