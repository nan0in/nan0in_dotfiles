# IDA 精细字体配置方案

## 字体分配策略

### 🎯 重要元素 - 大字体 (11pt)

使用 **Red Hat Display Medium/SemiBold** - 清晰醒目

| UI 元素 | 字体 | 大小 | 字重 | 用途 |
|---------|------|------|------|------|
| **菜单栏** | Red Hat Display | 11pt | Medium (500) | 主导航栏 |
| **状态栏** | Red Hat Mono | 11pt | Medium (500) | 关键信息显示 |
| **标签页** | Red Hat Display | 11pt | SemiBold (600) | 窗口标识 |
| **表头** | Red Hat Display | 11pt | Medium (500) | 列标题 |
| **Dock标题** | Red Hat Display | 11pt | Medium (500) | 窗口标识 |

### 📝 标准元素 - 中等字体 (10pt)

| UI 元素 | 字体 | 大小 | 字重 | 特点 |
|---------|------|------|------|------|
| **下拉菜单** | Red Hat Text | 10pt | Regular | 易读性好 |
| **工具栏** | Red Hat Display | 10pt | Medium (500) | 清晰明确 |
| **按钮** | Red Hat Text | 10pt | Medium (500) | 突出可点击 |
| **普通标签** | Noto Sans | 10pt | Regular | 通用文本 |
| **列表视图** | Noto Sans | 10pt | Regular | 清晰列表 |
| **组框标题** | Red Hat Display | 10pt | Medium (500) | 分组标识 |

### 💻 等宽字体 - 代码/数据 (10pt)

| UI 元素 | 字体 | 大小 | 用途 |
|---------|------|------|------|
| **输入框** | JetBrains Mono | 10pt | 代码输入 |
| **文本编辑器** | JetBrains Mono | 10pt | 多行文本 |
| **组合框** | JetBrains Mono | 10pt | 选项显示 |
| **状态栏** | Red Hat Mono | 11pt | 地址/偏移量 |

### ℹ️ 辅助元素 - 小字体 (9pt)

| UI 元素 | 字体 | 大小 | 用途 |
|---------|------|------|------|
| **工具提示** | Noto Sans | 9pt | 悬停提示 |

---

## 字体家族说明

### Red Hat Display
- **用途**: 重要标题、导航元素
- **特点**: 现代、清晰、专业
- **应用**: 菜单栏、标签页、表头、Dock标题

### Red Hat Text
- **用途**: 菜单项、按钮、对话框
- **特点**: 易读性好、适合正文
- **应用**: 下拉菜单、按钮、对话框

### Red Hat Mono
- **用途**: 等宽显示（状态栏）
- **特点**: 清晰的等宽字体
- **应用**: 状态栏（地址、偏移量等）

### JetBrains Mono
- **用途**: 代码编辑、数据输入
- **特点**: 专业编程字体、连字支持
- **应用**: 输入框、文本编辑器、组合框

### Noto Sans
- **用途**: 通用文本、列表、标签
- **特点**: 通用性好、多语言支持
- **应用**: 普通标签、列表视图、复选框

---

## 字体大小层级

```
11pt - 重要元素（菜单栏、状态栏、标签页、表头）
10pt - 标准元素（菜单、工具栏、按钮、标签、列表）
 9pt - 辅助元素（工具提示）
```

---

## 自定义调整

编辑 `~/ida_theme/user.css` 来调整字体大小：

### 增大菜单栏字体
```css
QMenuBar,
QMenuBar::item {
    font-size: 12pt;  /* 默认 11pt */
}
```

### 增大状态栏字体
```css
QStatusBar,
QStatusBar QLabel {
    font-size: 12pt;  /* 默认 11pt */
}
```

### 调整标签页字体
```css
QTabBar::tab {
    font-size: 12pt;  /* 默认 11pt */
    font-weight: 700; /* 默认 600 */
}
```

---

## 生效方式

1. 重启 IDA：`~/ida93`
2. 选择主题：Options → Colors → darcula
3. 验证效果

---

## 备份与恢复

### 当前配置备份
```bash
~/ida_theme/user.css.backup-maple-mono  # 全部 Maple Mono 的版本
```

### 恢复到之前的配置
```bash
cp ~/ida_theme/user.css.backup-maple-mono ~/ida_theme/user.css
```

---

## 配置文件位置

- 主题源: `~/ida_theme/user.css`
- IDA链接: `~/.idapro/themes/darcula/user.css → ~/ida_theme/user.css`
- 自动同步: 修改后重启 IDA 即可生效

---

## 字体安装验证

```bash
# 检查 Red Hat 字体
fc-list | grep "Red Hat"

# 检查 JetBrains Mono
fc-list | grep "JetBrains"

# 检查 Noto Sans
fc-list | grep "Noto Sans"
```
