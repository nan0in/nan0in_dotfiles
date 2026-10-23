# Nautilus：默认文件夹入口与个人配置

## 当前配置

- Nautilus 51.1 已安装，desktop ID 为 `org.gnome.Nautilus.desktop`。
- `Super+E`、截图／录屏文件夹、Dock／Shell 的本地目录入口使用系统默认处理器。
- 当前默认已设为 Nautilus，已通过实际 `Super+E` 同一路径打开其窗口验证。
- 不卸载 Thunar／Dolphin，不关闭其他窗口，不修改 Nautilus 现有偏好、书签或字体。

## 以后怎样更换默认文件管理器

图形入口：Clavis 设置 → 常规 → 默认应用 → 文件管理器，选择“文件／Nautilus”。
该页每次打开都会刷新系统默认值；其他入口下一次打开文件夹就跟随，无需重启 Niri。

命令行设置并检查：

```sh
xdg-mime default org.gnome.Nautilus.desktop inode/directory
xdg-mime query default inode/directory
# 预期：org.gnome.Nautilus.desktop
gio mime inode/directory
```

只改变目录关联，不把图片／文本等普通文件都设为由 Nautilus 打开。
依据：[xdg-mime 官方说明](https://portland.freedesktop.org/doc/xdg-mime.html)。

本机原 `~/.config/niri-mimeapps.list` 对目录强制指定 Dolphin，它的优先级高于普通
`~/.config/mimeapps.list`，所以以前改默认应用后可能仍打开 Dolphin。
本次仅去掉该目录覆盖项，保留文件和其他配置，再更新普通 MIME 文件的目录默认值。
以后不要在 `niri-mimeapps.list` 再添加矛盾的 `inode/directory` 条目；如需桌面专属覆盖，
明确知晓它优先于设置页。依据：[MIME 配置查找顺序](https://specifications.freedesktop.org/mime-apps/latest/file.html)。

## 配色跟随 Matugen

Clavis 内置 `gtk` Matugen 模板，输出到 `~/.config/gtk-4.0/gtk.css`，Nautilus 等
GTK4／libadwaita 应用会使用当前 Matugen 调色板。模板默认启用，可在
**设置 → 高级 → Matugen 模板** 中查看或关闭。

GTK4 只在应用启动时读取用户 CSS，所以切换壁纸／配色后需要重新打开 Nautilus：

```sh
nautilus -q          # 退出后台服务，已打开的文件窗口会关闭
nautilus ~           # 再打开
```

启用模板前应备份原有 `gtk.css`。本次修改前原件保存在：
`/home/nan0in/.local/state/clavis/gtk-theme-backup-20261023-151132/gtk.css`。
需要完全恢复旧文件时：

```sh
cp ~/.local/state/clavis/gtk-theme-backup-20261023-151132/gtk.css ~/.config/gtk-4.0/gtk.css
nautilus -q
```

Nautilus 51 的图标／列表选择框使用它自己的中性灰色，不跟强调色；强调色会出现在
开关、单选按钮、进度等控件上。这是 Nautilus 自身样式，不是 Matugen 模板缺失。

### 文件夹图标跟随 Matugen

Clavis 内置 `icons` Matugen 模板，把当前主色写入
`~/.local/share/clavis/profiles/default/generated/clavis/icon-primary`，并维护一个
`Tela-Matugen` 图标主题 overlay（继承当前 `Tela`／`Tela-dark`／`Tela-light`）。
它只重着色文件夹图标，应用图标和单色 symbolic 图标保持原样。

启用条件：系统当前图标主题必须是 Tela 系列。脚本首次运行时会切换到
`Tela-Matugen`；如果检测到你已手动选择其他图标主题，则跳过，不会覆盖你的选择。
overlay 位于 `~/.local/share/icons/Tela-Matugen`，状态位于
`~/.local/state/clavis/folder-icons/`；同名但非 Clavis 管理的目录不会被覆盖。

切换壁纸／配色后同样需要重新打开 Nautilus 才会看到新的文件夹颜色：

```sh
nautilus -q
nautilus ~
```

关闭 **设置 → 高级 → Matugen 模板 → icons** 时，Clavis 会恢复之前的 Tela 图标主题
并删除自己管理的 overlay。也可以手动恢复：

```sh
python3 ~/.config/quickshell/clavis/scripts/theme/icons_theme.py restore
```

如果之后改用其他图标主题，文件夹图标就不再跟随 Matugen，直到切回 Tela 系列。

## Nautilus 自身的设置

打开 Nautilus 后，右上角主菜单 → **首选项**，调整点击行为、排序、缩略图等。
视图按钮可切换图标／列表，视图菜单调整显示选项。
常用操作：`Ctrl+L` 输入完整路径；`Ctrl+H` 显示／隐藏隐藏文件；`Ctrl+D` 将当前文件夹加入书签。
官方说明：[文件管理器偏好](https://help.gnome.org/gnome-help/nautilus-prefs.html)、
[隐藏文件](https://help.gnome.org/gnome-help/files-hidden.html)。

以下是**可选命令**，本次未替你修改这些个人偏好：

```sh
# 默认列表视图；改回图标视图则使用 icon-view
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
# 双击打开；单击模式则使用 single
gsettings set org.gnome.nautilus.preferences click-policy 'double'
# 默认显示隐藏文件；关闭则使用 false
gsettings set org.gnome.nautilus.preferences show-hidden-files true
# 始终使用可编辑路径栏；关闭则使用 false
gsettings set org.gnome.nautilus.preferences always-use-location-entry true
# 只读查看当前全部偏好
gsettings list-recursively org.gnome.nautilus.preferences
```

这些键已按本机 51.1 的 schema／可选值核对。设置存于 GSettings/dconf，不建议直接编辑二进制 dconf 文件。
Nautilus 使用 GTK4/libadwaita，不使用 Thunar 的 GTK3 Material 皮肤；本次不注入或强改它的 CSS。

## 备份与恢复

修改个人偏好之前可手动导出：

```sh
dconf dump /org/gnome/nautilus/ > "$HOME/nautilus-preferences.backup.ini"
# 仅在需要恢复该备份时运行：
dconf load /org/gnome/nautilus/ < "$HOME/nautilus-preferences.backup.ini"
```

本次目录关联及路由脚本修改前的原件保存在：
`/home/nan0in/.local/state/clavis/nautilus-20261022-233534/`。
其中 `mimeapps.list.before`、`niri-mimeapps.list.before` 是原始个人配置，
`desktop_tools.py.before` 是旧的 Thunar 优先实现。不要为了更换默认程序整份覆盖这些备份，
日常只使用上面的默认应用设置即可。
