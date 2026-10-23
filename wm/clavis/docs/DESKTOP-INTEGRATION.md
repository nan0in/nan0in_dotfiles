# Dracula、Waywallen 与截图编辑

## Qt 与 GTK：分层管理

- GTK3 已选择独立 `Clavis-Material-Dracula`，Material 圆角 Dracula；字体与其余个人设置保留。
- Qt Widgets 改用 **Clavis Material Dracula**：KvAdaptaDark 的扁平控件与间距，搭配 Dracula 深色。
  它是 Material 风格适配，不是把 Dolphin 改造成 Google 官方 Material 3 应用。
- `qt6ct` 统一管理样式和调色板。niri 对 `QT_STYLE_OVERRIDE` 使用 `null`，Clavis 服务也不继承这个强制样式变量，
  避免它覆盖你后来在 qt6ct 选择的控件样式。
- Qt 全局字体、图标不变。Dolphin 单独使用 `ClavisDracula` 配色和 `breeze-dark` 图标，解决深色背景上的黑色图标。
- Dolphin 在非 KDE 会话的自动配色可能重新套用 Breeze，造成 Qt 控件与文字/背景不一致；
  因此明确写入它的 `[UiSettings] ColorScheme=ClavisDracula`，不是只更改 Qt 调色板。
  依据：[KColorSchemeManager](https://github.com/KDE/kcolorscheme/blob/master/src/kcolorschememanager.cpp)。
- 独立主题链接到 `~/.config/Kvantum/ClavisMaterialDracula`，不修改系统主题或原 KvDark 文件。
  本地 SVG 衍生主题保留上游原件、版本及 GPL 许可证；KDE 调色板沿用 MIT 许可的 Dracula 颜色。
- 精确调整 `qt6ct.conf` 的三项 Appearance 值、Kvantum 的主题名、Dolphin 的两个外观项；
  不替换整个 Dolphin 配置，不改 `kdeglobals`、字体、视图、工具栏、快捷键或默认目录。
- 配置修改前留存备份；记录在 `~/.local/state/clavis/appearance-install.json`。
- 重新打开的 Dolphin/Qt 应用使用新样式；已有应用不被强制关闭。Electron、libadwaita 等仍有各自主题机制。

仓库根目录应用、选择原来的 Fusion 控件或回退上一次应用：

```sh
./scripts/setup-clavis.sh appearance
python3 scripts/clavis-appearance.py apply --style fusion
python3 scripts/clavis-appearance.py restore
```

`restore` 一次恢复最近一层应用记录；若配置有后续个人修改，则整组保留而不是部分回滚。
主题素材链接保留，便于以后自行选择。不会为换主题重启 niri 或关闭应用。

## 剪贴板设置与现有文件重名

本机 `key-cli` 默认配置目录与已有个人文件重名，导致 `clipboard config` 报 Not a directory。
没有读取、迁移、重命名或替换那个个人文件。

仅剪贴板子进程的 `XDG_CONFIG_HOME` 改为：

```text
~/.config/niri-clavis/settings/key-cli-config
```

实际上限配置写到其下 `key/clipboard.json`。Clavis 的读写、列表、恢复/删除/预览和 watcher
使用相同配置根；其他 key 功能及外部应用仍使用原来的 XDG 目录。
设置 → 常规 → Spotlight → 剪贴板：历史上限已验证可读，可按 50 步进保存。
默认仍为 500，不清理历史、不迁移旧数据库。数据库及缓存路径没有改动。

独立命令检查（只读取设置，不输出剪贴板内容）：

```sh
env XDG_CONFIG_HOME="$HOME/.config/niri-clavis/settings/key-cli-config" \
  "$HOME/.local/opt/nan0in-clavis-deps/key-cli/bin/key" clipboard config --format json
```

## Clavis 配色不再依赖静态壁纸

设置 → 主题 → **配色来源**：

- **强调色**：输入 `#RRGGBB` 后“应用”；默认 Dracula 紫 `#bd93f9`。
- **壁纸**：Waywallen 运行时读取其当前壁纸预览图取色；否则使用 Clavis 自己选择的图片／颜色。
- 下方 Matugen 配色方案立即从所选来源重新生成；没有来源时显示错误，不再默默无变化。

设置保存于 `~/.config/niri-clavis/settings/ui-preferences.json` 的 `themeColorSource`、`themeAccentColor`。
生成的面板颜色在 `~/.local/share/clavis/profiles/default/generated/clavis/colors.json`。
这是 Shell 配色，和 Qt 应用的固定 Dracula 调色板各自独立。

为保留现有个人主题，首次接入关闭 btop/cava/gtk/kitty/yazi 的外部模板写入；面板配色照常生成。
若以后在模板设置中主动启用，它们会写入列出的目标路径，部分带应用重载 hook；请先查看路径与备份。

GTK 模板写入 `~/.config/gtk-4.0/gtk.css`，让 Nautilus 等 GTK4／libadwaita 应用跟随 Matugen 配色。
GTK4 只在应用启动时读取用户 CSS；切换主题后需重新打开 Nautilus（可先 `nautilus -q` 退出后台服务）。
该模板会整份覆盖 `gtk.css`，启用前先备份原文件。

`icons` 模板维护继承 Tela 系列的 `Tela-Matugen` 图标主题 overlay，只把文件夹图标的蓝色强调色换成当前主色；应用图标不变。
当前图标主题不是 Tela／Tela-dark／Tela-light 时会跳过，不覆盖手动选择。切换配色后同样需要重新打开 Nautilus。

## Waywallen：保留动态壁纸与原生配置方式

设置 → 壁纸，顶部显示 **Waywallen**、当前名称、预览，以及：

- **打开 Waywallen**：使用现有管理器切换动态壁纸与 Wallpaper Engine 项目。
- **使用壁纸配色**：仅拿预览图生成 Clavis 颜色，不把动态场景换成静态图。
- **Super+Ctrl+Shift+W**：直接打开 Waywallen；原 Super+Shift+W 仍打开 Clavis 壁纸搜索。

桥接每 5 秒只读检查 Waywallen TOML、SQLite 中的当前选择和现有 layer-shell socket，
不读取插件 cookie，不写数据库、不停止渲染器。预览是选中项目的缩略图，并非动态画面实时录制。
桌面壁纸管理器的同一下拉现在提供 Waywallen / Quickshell / awww，始终可见。
按选中的后端而非进程是否存在来切换：Waywallen 隐藏 Clavis 桌面背景表面，静态图片与过渡设置保留，
切回后可继续使用；概览背景等独立功能不受影响。动态场景与视频的详细选项仍在 Waywallen 内调整。
上一张／下一张接其原生 D-Bus 接口，不直接写外部数据库；不擅自结束外部管理器。

## 截图：niri 采集，Satty 编辑

| 快捷键 | 功能 |
|---|---|
| Print / Super+R | 选区 → Satty |
| Ctrl+Print | 当前屏幕 → Satty |
| Alt+Print | 当前窗口 → Satty |
| Shift+Print | 区域、窗口、屏幕、全部屏幕、延迟、鼠标及可选 Spectacle |
| Super+Alt+Print | 保留原生 niri 截图入口 |

按你要求恢复更适合当前 Wayland 主题的原 Satty，沿用个人 Satty 配置，不另装 Gradia。
截图仍由 niri/grim 完成；Satty 原生 Wayland 编辑。手动选 Spectacle 时仅编辑器走 XWayland，
无 DISPLAY 则回退 Satty，不修改桌面会话类型，也不把 Spectacle 的 KWin 捕获当成 niri 功能。
每次截图独立临时目录；取消不打开旧图，不覆盖旧截图，原 niri 脚本与个人编辑器配置保留。

## 托盘折叠弹层与屏幕边缘绿线

托盘折叠框已从手算全局坐标的 layer-shell 窗口改为原生按钮锚定 PopupWindow。
原因是 Wayland 不保证 layer-shell 窗口的全局位置，原逻辑会把底栏弹框夹到屏幕顶部。
独立 niri 中已复现旧问题并验证底栏上弹、外部点击关闭；箭头随上下左右边缘旋转。
托盘右键菜单继续使用现有原生锚定方式；未修改个人托盘常驻/折叠列表。

右侧绿线已完成交替验证：eDP-1 最右四列在 Vulkan 解码下始终呈绿色，切换软件解码消失，
切回 Vulkan 再现，最终软件解码再次消失；未遮盖、裁掉边缘或替换原视频。
当前仅通过 Waywallen 原生设置 API 将视频 `hwdec` 从 `auto` 改为 `none`，其余 TOML 配置语义一致。
VA-API 在本机实际回退为软件，未误报硬解成功。兼容模式可能增加 CPU 开销；以后可在其视频设置里改回 `auto`。
备份和像素／解码标签对比：`~/.local/state/clavis/completion-20261022-002048/`。

## 当前外观设置入口

设置 → 主题 → 应用外观：GTK3、应用图标、Qt6 样式／配色、Kvantum 主题，均附方案描述。
不再固定会话 GTK_THEME，Shell 也清除继承的强制样式；新打开应用遵循各自设置。
Kvantum 主题和 Qt 配色独立，GTK4/libadwaita 与 Qt5 不强制跟随。本次原 GTK 字体及无关行逐字保持。
Yazi 使用独立 overlay，模板关闭恢复原主题链接；详见 [日常指南](START-HERE.md)。

实际排查确认：Wayland GTK 从 GSettings 读取，XWayland GTK 从 XSettings 读取，
仅改 settings.ini 会被二者覆盖。现在 GTK／图标操作同步这三处，事务失败回滚，字体／DPI／其他键原样保留。
原始 GSettings 值及配置副本保存在同一次 appearance-backups 记录中。
现有 xsettingsd 仅重读配置，不重启用户应用；实际两个 GTK 后端均确认主题正确、个人字体不变。
依据：[GSettings](https://docs.gtk.org/gio/class.Settings.html)、
[xsettingsd 信号入口](https://github.com/derat/xsettingsd/blob/master/xsettingsd.cc)。
