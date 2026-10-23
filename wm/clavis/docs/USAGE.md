# 登录、日常使用与排障教程

## 1. 下次登录

保存工作，正常注销；在原登录界面选择 **Niri**。无需新命令、单独会话或自定义二进制。
本次只调整下一次 niri.service 启动参数，没有重启你当前的 niri。

启动顺序：

```text
原 Niri 登录项 → niri-session → niri.service
  → 80-clavis.conf 指定 niri-clavis/config.kdl
  → startup.sh 导入本会话环境
  → fcitx5、polkit
  → 原 idle/sleep-lock 服务 + Clavis Shell/剪贴板
  → 延迟启动托盘应用
```

旧 Hyprland/Ambxst、旧 niri 主配置与服务文件均保留，不是全局替换桌面。

## 2. 第一次使用

1. Super+Q 打开 Kitty，Super+E 跟随系统默认文件管理器（当前 Nautilus）。
2. Super+Space 搜索应用；Super+Ctrl+Space 始终可开独立 Fuzzel。
3. Super+D 打开 Dashboard，Super+A 打开快速设置，Super+Shift+C 打开设置中心。
4. Super+V 打开新剪贴板历史；Super+Period 打开保留的 Emoji 选择器。
5. Super+N 编辑随手记，Super+T 进入 tmux main。
6. Super+Shift+W 选择 Clavis 壁纸；旧 Waywallen 资源不会自动成为 Clavis 壁纸库。
7. Super+L 锁屏；Super+Escape 电源菜单。建议完成一次真实密码解锁和休眠恢复验收。
8. Super+F1 搜索当前完整快捷键；Enter 选择不会执行命令，只作提示。

方向导航优先用方向键；Super+J 是列布局显示切换，不再是向下聚焦。
完整差异：[Ambxst 迁移对照](MIGRATION-FROM-AMBXST.md)。

## 3. 截图、文字识别与录屏

- Super+R / Print：框选 → Satty 编辑；Ctrl+Print 为屏幕，Alt+Print 为窗口。Shift+Print 打开高级截图菜单。
- Satty 提供标注、复制和另存为；菜单可选择 Spectacle，原配置及其快捷操作保持不变。详见 [截图与桌面集成](DESKTOP-INTEGRATION.md)。
- Super+Shift+A：框选 → Tesseract 简中/英文 OCR → 复制文字。
- Super+Shift+R：框选并开始无音频录屏；再按同键停止。录屏 backend 状态：

```sh
~/.local/opt/nan0in-clavis-deps/key-cli/bin/key record status --json
```

截图标注不删除之前进入历史的原图。处理敏感内容前可暂时停止历史服务：

```sh
systemctl --user stop clavis-clipboard.service
# 处理完成且确认可以恢复记录后
systemctl --user start clavis-clipboard.service
```

若你按需启动过 Vicinae，也应检查它自己的历史设置，而不只停 Clavis watcher。

## 4. 面板、通知、托盘故障

```sh
systemctl --user status clavis-shell.service clavis-clipboard.service
journalctl --user -u clavis-shell.service -b -n 100
journalctl --user -u clavis-clipboard.service -b -n 100
```

- Super+Alt+B：重启 Shell 与 clipboard watcher，不重启 compositor。
- Super+Shift+B：托盘恢复；重启 Shell，并重新启动属于本 Wayland 会话的托盘 applet。
- Super+Ctrl+Alt+B：停止 Shell 和 watcher，终端/窗口/工作区/原锁屏仍独立工作。
- 面板完全不可用时，用 Super+Q 打开终端执行：

```sh
systemctl --user restart clavis-shell.service clavis-clipboard.service
```

通知仅由一套服务处理。新会话若仍看见旧 Waybar/Mako，先查看：

```sh
systemctl --user status niri-panel.service niri-notifications.service
```

它们在新启动脚本中不会启动；不要为了“恢复”而同时启动两套 Shell/通知服务。
输入法/认证问题查看 `~/.local/state/clavis/startup.log`，检查 fcitx5 与 polkit agent。

## 5. 确认下一次使用了正确配置

```sh
systemctl --user show niri.service -p Environment -p MainPID
niri validate -c ~/.config/niri-clavis/config.kdl
systemctl --user cat niri.service
```

Environment 中应看到绝对路径的 NIRI_CONFIG 指向 niri-clavis/config.kdl。
**当前服务的 Environment 配置不等于运行中的旧进程已经切换**；本次需正常重新登录。

## 6. 安装、升级、Qt 更新

在 dotfiles 根目录执行：

```sh
./scripts/setup-clavis.sh check
./scripts/setup-clavis.sh deps
./scripts/setup-clavis.sh build
./scripts/setup-clavis.sh install
```

`check` 仅预检链接冲突，不表示依赖/运行时全部健康。
`deps` 为 Arch 用户前缀安装，不执行 sudo 或系统 pacman 事务；签名来自本机 Arch keyring。
需要已安装 uv、Git、CMake、Ninja、编译器及 Qt 基础开发包。不是任意空系统的一键安装器。

Qt ABI 更新后同时重建用户前缀 M3Shapes 等依赖与 Clavis。Arch 数据库如果落后于镜像，
包下载 404，应先自行正常更新系统数据库/系统，避免手工混用另一套 Qt。
源码升级不要直接覆盖本地已定制文件；先对照 UPSTREAM 的固定提交，在独立临时 checkout
比较上游差异，再有选择地合并。当前源码副本不是含上游历史的 git submodule。

## 7. 回到原桌面

Hyprland/Ambxst：退出当前会话，在登录界面选原 Hyprland。
回到原 niri 配置：只删除本次增加的配置选择链接，再清掉 manager 的临时环境：

```sh
# 先核对该链接确实属于本仓库
readlink ~/.config/systemd/user/niri.service.d/80-clavis.conf
rm ~/.config/systemd/user/niri.service.d/80-clavis.conf
systemctl --user daemon-reload
systemctl --user unset-environment NIRI_CONFIG
```

随后正常注销并选 Niri。撤销全部六个新增链接可执行 `./scripts/setup-clavis.sh uninstall`。
该操作不删源码/依赖/个人设置，不在运行中强制切换配置；应退出当前会话后再完整卸载，
避免运行中的配置目录被移走。后续 `install` 会再次接入默认 Niri 登录。

## 8. 验证边界与首次登录验收

本轮已做：niri 配置解析、当前有效键位清单、服务单元校验；隔离嵌套 niri 中的
工作区全浮动/恢复、混合窗口收敛及焦点保留；随手记不覆盖和录屏状态分发/OCR 临时文件
清理的模拟外部工具测试。没有对当前桌面进行锁屏、录制或读取真实剪贴板的测试。

首次登录还需你实际确认：双屏导航、Super+L 密码解锁、Super+J 标签显示、
工作区浮动、Emoji、中文输入、区域 OCR 识别准确度、录屏文件播放、托盘恢复、
休眠/唤醒和 Clavis UI 的电源操作。模拟测试不代表这些真实交互已经验收。
