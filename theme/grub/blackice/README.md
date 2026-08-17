## Preview

![preview](preview.png)

## 安装

```bash
sudo ./install.sh 1600
```

当前配置面向 2560x1600 屏幕，安装脚本会设置:

```bash
GRUB_GFXMODE="2560x1600,2560x1440,1920x1080,auto"
```

## 预览

```bash
grub2-theme-preview --resolution 1440x900 --display gtk,zoom-to-fit=on blackice
```

## 手动安装

```bash
sudo cp -r blackice /boot/grub/themes/
# /etc/default/grub 中设置:
#   GRUB_THEME="/boot/grub/themes/blackice/theme.txt"
#   GRUB_GFXMODE="2560x1600,2560x1440,1920x1080,auto"
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 当前定制

- 原主题: TomorrowX6/arch-grub
- 原地址: https://github.com/TomorrowX6/arch-grub
- 背景: `nan0in_banner.png`
- 字体: Maple Mono NF CN (`.pf2` 已内置到主题目录)
- 启动项列表: 20 号 Maple Mono NF CN，使用无白色外边框的选中高亮
- 进度条: 使用 `progress_modern_*` 扁平样式
- 底部快捷键提示: 20 号 Maple Mono NF CN

## 致谢

- Arch 娘立绘:[ravimo — pixiv 101776734](https://www.pixiv.net/artworks/101776734)
- 字体: Maple Mono NF CN
