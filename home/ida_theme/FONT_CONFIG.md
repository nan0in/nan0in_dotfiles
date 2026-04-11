# IDA 字体配置说明

## 问题
IDA 9.3 顶部菜单栏字体与设定的 Maple Mono 不一致

## 原因
IDA 的字体设置分为两部分：

1. **反汇编视图字体**（通过 IDA 设置界面配置）
   - Options → Font → 设置为 "Maple Mono"
   - 影响：反汇编窗口、十六进制窗口、调试器窗口

2. **UI元素字体**（通过 Qt CSS 主题配置）
   - 菜单栏、工具栏、对话框等
   - 需要在主题CSS文件中设置

## 解决方案

已在 `~/ida_theme/user.css` 中添加全局字体设置：

```css
/* 全局字体设置 */
* {
    font-family: "Maple Mono NF CN", "Maple Mono", monospace;
}

QMenuBar, QMenu, QToolBar, QStatusBar, QDialog, 
QWidget, QPushButton, QLabel, QTabBar::tab {
    font-family: "Maple Mono NF CN", "Maple Mono", monospace;
}
```

## 使用方法

1. **重启 IDA 9.3** 以加载新的主题配置：
   ```bash
   ~/ida93
   ```

2. **确认主题已激活**：
   - Options → Colors → 选择 "darcula"

3. **验证字体**：
   - 检查菜单栏是否使用 Maple Mono 字体
   - 检查工具栏、状态栏等UI元素

## 自定义字体大小

如果需要调整菜单栏字体大小，编辑 `~/ida_theme/user.css`：

```css
QMenuBar, QMenu {
    font-size: 10pt;  /* 修改此值 */
}
```

## 备注

- 由于使用符号链接，修改 `~/ida_theme/user.css` 会自动同步到 IDA
- 修改后需要重启 IDA 才能看到效果
- 如果字体仍未生效，检查系统是否正确安装了 Maple Mono 字体

## 验证字体安装

```bash
fc-list | grep -i maple
```

应该能看到多个 Maple Mono 字体变体。
