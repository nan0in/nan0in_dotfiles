## blog-dark

Cross-platform input method theme spec for the `blog-dark` look.

### Linux source of truth

- fcitx5 theme config: `fcitx5/.local/share/fcitx5/themes/blog-dark/theme.conf`
- fcitx5 assets: `fcitx5/.local/share/fcitx5/themes/blog-dark/*.png`
- fcitx5 activation: `fcitx5/.config/fcitx5/conf/classicui.conf`

### Theme intent

- Tokyo Night dark base
- muted blue-purple highlight
- soft border, low-contrast separators
- horizontal candidate list
- frosted-glass feel on Linux

### Windows Weasel notes

Weasel cannot directly reuse the fcitx5 PNG panel, blur mask, or KWin blur effect.
The Windows version therefore uses the same palette and spacing intent, with a close solid-color approximation.

### Deploy on Windows

1. Copy `input-themes/blog-dark/weasel/weasel.custom.yaml` to `%AppData%\Rime\weasel.custom.yaml`.
2. If you already have a `weasel.custom.yaml`, merge the `patch:` block instead of overwriting it.
3. Right-click 小狼毫 and choose `重新部署`.
4. Select the `blog_dark` color scheme if it is not already active.

### Palette reference

- background: `#1a1b26`
- text: `#a9b1d6`
- selected text: `#b0b8f0`
- accent blue: `#7aa2f7`
- highlight bg: `#505aa0`
- border: `#414868`
- preedit accent: `#e0af68`
