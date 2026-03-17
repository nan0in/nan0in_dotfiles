# nan0in_dotfiles
> [!IMPORTANT]
> 已经重装3次Arch Linux

nan0in's dotfiles from his arch-linux, keep exploring  
使用 [GNU Stow](https://www.gnu.org/software/stow/) 管理配置文件，通过符号链接让 `$HOME` 下的文件直接指向此仓库，编辑即追踪。

## 快速安装（新机器）

```bash
git clone git@github.com:nan0in/nan0in_dotfiles.git ~/projects/nan0in_dotfiles
cd ~/projects/nan0in_dotfiles
bash install.sh
```

脚本会把 `config`、`fcitx5`、`home` 三个包 stow 到 `$HOME`，并从 `.zshrc.secrets.example` 生成 `~/.zshrc.secrets`（填入你的 API key 等敏感值）。

> `theme/` 包含 SDDM/grub 主题，需要 root 权限手动安装，不在脚本范围内。

### Stow 包结构

| 包 | 内容 |
|---|---|
| `config/` | `~/.config/` 下的所有配置（nvim、kitty、ranger、yazi、fontconfig 等） |
| `fcitx5/` | fcitx5 主题及输入法配置 |
| `home/` | `~/.zshrc`、`~/.p10k.zsh`、tmux 配置等 |
| `theme/` | SDDM / grub 主题（需 root，手动安装） |

## 探索和收集配置文件
如果你是第一次收集配置文件（在写这个文档的时候我也是），就推荐使用`--adopt`转移一系列的配置文件，参考[chaneyzorn](https://github.com/chaneyzorn/dotfiles?tab=readme-ov-file)的方法你就可以轻松实现一系列dotfiles的构建啦。  
1. 在home目录下创建`stow dir`，我的是`nan0in_dotfiles`
2. 在`stow dir`下分类创建配置文件的文件夹，如`nan0in_dotfiles/zsh`
3. 在`zsh`文件夹下创建对应配置文件或文件夹
4. 在`stow dir`下`stow --adopt zsh`便会对比`target dir`和真实的zsh目录结构并将同树结构的文件引入到`stow dir`，也就是.zshrc会移动过来进行覆盖，在我们的真实目录（HOME .config等等）便会创建符号链接指向转移过来的配置文件
然后我们就可以如法炮制进行添加

### 管理
使用git和lazygit进行管理，既方便管理也方便在另外的电脑上配置，一些关于`stow dir`的操作如下：  
- `-d`指定stow文件夹
- `-t`指定target文件夹
- `-D`移除已创建的文件树
- `-S`创建指定文件树
- `-R`移除并重新创建指定文件树  
注意了当文件存在发生冲突，一可以删掉已存在文件，二可以`--adopt`选项+git操作将已存在配置文件移动到已在git管理下的`stow dir`选择性操作文件，git commit并checkout

## 依赖清单（Arch Linux）

### 基础工具

```bash
sudo pacman -S stow git lazygit
```

### Shell

```bash
# oh-my-zsh（需联网下载）
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 插件（需联网 clone）
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
# p10k（需联网 clone）
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
# 美化依赖
sudo pacman -S fortune-mod cowsay lolcat fastfetch
# ls 替代 & 路径跳转
sudo pacman -S eza zoxide
# uv Python 包管理器（需联网）
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 终端

```bash
sudo pacman -S kitty
```

### tmux

```bash
sudo pacman -S tmux xclip       # xclip 用于 tmux 复制到系统剪切板
# 插件管理器 & 插件（需联网 clone）
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect
git clone https://github.com/tmux-plugins/tmux-sensible ~/.tmux/plugins/tmux-sensible
git clone https://github.com/dracula/tmux ~/.tmux/plugins/dracula
# tmux-thumbs（需要 Rust/Cargo）
sudo pacman -S rust
git clone https://github.com/fcsonline/tmux-thumbs ~/.tmux/plugins/tmux-thumbs
~/.tmux/plugins/tmux-thumbs/tmux-thumbs.sh   # 编译
# 安装完插件后在 tmux 中按 prefix + I 加载所有插件
```

### 编辑器

```bash
sudo pacman -S neovim
# avante.nvim 构建依赖
sudo pacman -S make cmake
# kd 翻译（nan0in-plugins.lua 中使用，AUR）
yay -S kd
# 字体：Maple Mono NF CN（从 nan0in 自托管 release 下载）
mkdir -p ~/.local/share/fonts/MapleMono
curl -L -o /tmp/MapleMono-NF.zip https://github.com/nan0in/maple-font/releases/download/v1773727790/MapleMono-NF.zip
unzip -o /tmp/MapleMono-NF.zip -d ~/.local/share/fonts/MapleMono/
fc-cache -fv
```

### 输入法

```bash
sudo pacman -S fcitx5 fcitx5-chinese-addons fcitx5-configtool fcitx5-qt fcitx5-gtk
```

### 文件管理 / yazi 预览依赖

```bash
sudo pacman -S yazi ranger btop
# yazi 预览所需工具
sudo pacman -S chafa ffmpegthumbnailer poppler   # 图片/视频/PDF 预览
yay -S resvg                                     # SVG 预览
# yazi 插件（package.toml 中已声明，进入 yazi 后运行 ya pkg install）
```

### 其他常用工具

```bash
# go 版本管理（.zshrc 中使用 gvm）
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
# nvm（Node.js 版本管理）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
# miniforge3（conda/mamba Python 环境）
# 下载地址：https://github.com/conda-forge/miniforge/releases/latest
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh
```

### 音乐

```bash
# go-musicfox（需联网，AUR 或 go install）
yay -S go-musicfox
# 或者用 go 安装
go install github.com/go-musicfox/go-musicfox@latest
```

## 截图 & 功能介绍

### 桌面 (KDE Plasma)
终端: kitty，Shell: oh-my-zsh + powerlevel10k，字体: Maple Mono NF CN

### 输入法
fcitx5 + 手搓的主题 `blog-dark`（Tokyo Night 毛玻璃磨砂暗色，位于 `fcitx5/` 包）
<img width="822" height="88" alt="image" src="https://github.com/user-attachments/assets/a443702c-10c0-497e-85aa-71b569a378a5" />


### Shell
oh-my-zsh + powerlevel10k，统一配色: Dracula & Tokyo Night

### tmux
![image](https://github.com/user-attachments/assets/55f1aab9-9410-4d43-baa1-43b8adfee067)

### Neovim (LazyVim)
antigravity for vibe coding  
<img width="2559" height="1525" alt="image" src="https://github.com/user-attachments/assets/66219859-57b6-4cb9-ba96-98dc43703fc5" />

<img width="2560" height="533" alt="image" src="https://github.com/user-attachments/assets/00cf4ff4-967d-4332-902b-11a197449254" />

### 常用软件
| 工具 | 用途 |
|---|---|
| wps-office | 替代 Microsoft Office |
| draw.io | 绘图 |
| drawpen | 快速批注 |
| goldendict | 字典 |
| IMHEX | 十六进制编辑器 (类 010editor) |
| yazi / ranger | 文件管理 |
| btop | 进程管理 |
| virt-manager + qemu/kvm | 虚拟机 |
| codesnap | 代码截图 |
| VLC | 视频播放 |
| go-musicfox | 命令行音乐 |

## license
- MIT
