# Clavis Material Dracula

Qt Widgets 的 KvAdaptaDark 衍生主题：保留 Material 风格的控件形状与间距，将背景和强调色调整为 Dracula。
不是 Google 官方 Material 3，也不替换 Dolphin 的功能或界面结构。

- 上游：<https://github.com/tsujan/Kvantum>，V1.1.8，commit 见 UPSTREAM.json。
- `upstream/` 为固定版本原件；`ClavisMaterialDracula/` 为 2026-10-21 本地改色版本。
- 作者：Tsu Jan；修改：nan0in dotfiles 本地配色适配。
- 两份均依上游 GPL-3.0-or-later 发布，完整许可证见 upstream/COPYING。
- SVG 保留所有几何与控件 ID，仅改变颜色；kvconfig 调整颜色与说明。
- `scripts/clavis-appearance.py apply` 创建独立主题链接，只改 Qt 外观相关设置，保留字体与全局图标；Dolphin 单独使用深色可读图标。
