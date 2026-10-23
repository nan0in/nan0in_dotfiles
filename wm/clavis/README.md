# niri + Clavis（默认 Niri 登录直接使用）

Clavis 是 StatIndet/quickshell 当前的项目名；Quickshell 是运行框架。
这里是 dotfiles 内可编辑的上游源码副本，来源与固定提交见 `UPSTREAM`。
保留 GPL-3.0 和第三方许可证；尚未创建 GitHub 平台的远端 fork。

## 下次启动

保存工作后正常注销，在原登录界面选择 **Niri** 即可。
不需要自定义命令，不新增会话入口，不安装 `nan0in-clavis` 可执行文件。
当前已使用 Clavis；后续修改只刷新 Shell，不重启 niri。

接入方式为 `~/.config/systemd/user/niri.service.d/80-clavis.conf`：仅设置
niri 服务下次启动时的 `NIRI_CONFIG=~/.config/niri-clavis/config.kdl`。
原 `~/.config/niri/config.kdl` 和 startup.sh 保留原样。
配置内的 startup.sh 导入会话环境，然后启动 `clavis-shell.service` 和
`clavis-clipboard.service`，均随 niri 退出而停止，不是全局桌面自启。

保留 fcitx5、polkit、托盘应用、niri-idle/niri-sleep-lock。
旧 Waybar/Mako/Vicinae/Waywallen 未卸载、修改或 disable，但不由新启动流程启动；
Clavis 提供面板、通知、Spotlight、壁纸。旧动态壁纸资源保留，不自动接管。
Clavis 自身 idle policy 默认关闭，继续使用已有 swayidle（Clavis 锁屏，swaylock 故障兜底），避免双重锁屏。
Super+L、合盖、闲置与睡眠前调用 niri-clavis/scripts/lock.py，读取设置中的锁屏样式。
睡眠前跳过截图等待；独立监测进程在锁屏崩溃时接管。Super+Alt+L 为红屏时仍可用的 swaylock 应急恢复键。
真实密码解锁和休眠恢复仍需会话验收；原 niri 配置与锁屏脚本不改动。

## 安装与更新

仓库根目录：

```sh
./scripts/setup-clavis.sh check
./scripts/setup-clavis.sh deps
./scripts/setup-clavis.sh build
./scripts/setup-clavis.sh install
```

从旧版的双层快捷键布局更新时，先执行 `./scripts/setup-clavis.sh migrate-bindings`；
它会备份并合并当前有效绑定，之后再 install。当前机器已经迁移。

安装器遇到已有非本仓库目标文件时停止，不 adopt、不覆盖；安装后仅执行
systemd daemon-reload，不重启 niri 或当前 Shell。
配置模板在 `wm/clavis/.config/niri-clavis/`，运行配置使用真实可写目录。
主 install.sh 默认包列表未加入 Clavis，使用这里的专用安装脚本管理。
依赖位于 `~/.local/opt/nan0in-clavis-deps/`，下载缓存位于
`~/.cache/nan0in-clavis-build/`，无 sudo 和系统包变更。
Arch 包验签、固定源码版本及 key-cli 校验记录见依赖目录的 installed.json。
Qt/Arch 更新后应重新构建依赖和 Shell，避免 ABI 不匹配。

## 定制入口

- `.local/src/clavis/`：直接改上游 QML/C++；原生代码修改后重新 build。
- `~/.config/niri-clavis/personal-base.kdl`：本机既有 niri 配置快照，去掉旧自启行，保留基础设置。
  显示器、缩放、输入法、窗口规则保留；快捷键已归入下方 UI 片段。
- `~/.config/niri-clavis/shell-binds.kdl`：旧 include 兼容空入口，不再重复定义按键。
- `~/.config/niri-clavis/clavis/binds.kdl`：窗口／工作区／Shell 快捷键的单一入口，可在设置中编辑、删除。
- `~/.config/niri-clavis/local.kdl`：最后加载的个人覆盖，安装器不重写。
- `~/.config/niri-clavis/clavis/`：Clavis UI 显式写入的可选 niri 片段。
- `~/.config/niri-clavis/settings/`：Clavis 设置存储，独立于其他 Shell 的配置。
  运行后新生成的个人数据默认不进入 Git；初始 idle 策略单独跟踪。

快照不自动跟随旧 niri 的后续修改；有意合并需要的差异即可。旧 niri 脚本仍通过原路径
调用，所以当前 profile 依赖本机原 `~/.config/niri/scripts/`，不是可脱离旧配置的跨机器
完整 niri 发行版。这样避免复制或覆盖你已维护的个人脚本。

## 使用和定制文档

- [从零到日常使用（先读这一份）](docs/START-HERE.md)
- [wrong.md 逐项处理与验收](docs/WRONG-FIXES.md)

- [登录、日常使用、排障与回退教程](docs/USAGE.md)
- [配置结构与定制方法](docs/CONFIGURATION.md)
- [Ambxst/Hyprland 迁移对照与差异](docs/MIGRATION-FROM-AMBXST.md)
- [当前完整快捷键（从配置生成）](docs/KEYBINDINGS.md)

已按确认恢复 Super+L 锁屏、Super+J 列显示切换；方向键优先。
默认文件管理器、Dashboard、工作区整体浮动、托盘恢复，并补上区域录屏/OCR、随手记、
按需 Emoji 和读取新 include 链的 F1 帮助。各项与原 Ambxst 的差异详见对照文档。

## 验证、服务和回退

```sh
niri validate -c ~/.config/niri-clavis/config.kdl
systemctl --user status clavis-shell.service clavis-clipboard.service
journalctl --user -u clavis-shell.service -b -n 100
```

当前 Niri 会话已使用这套服务；新机器首次安装需要正常注销登录来启用会话自启。
必要时通过 systemctl --user restart/stop 管理服务，不提供额外包装命令。

恢复原 Niri 启动配置：移除本次新增的 80-clavis.conf 软链接，执行
`systemctl --user daemon-reload` 和 `systemctl --user unset-environment NIRI_CONFIG`，
然后正常注销、重新登录 Niri。
要一并撤销本次所有新增链接，在仓库根目录执行：

```sh
./scripts/setup-clavis.sh uninstall
```

卸载只移除仍指向本仓库的六个链接，不删除源码、依赖、设置或旧个人配置。
本次已经移除旧的 nan0in-clavis 包装命令，其脚本备份仅存放在
`~/.local/state/clavis/retired-session-wrapper-20261021/`，不在 PATH 中。
