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
| `config/` | `~/.config/` 下的所有配置（hypr、nvim、kitty、mako、ranger、yazi 等） |
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
# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 插件
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
# p10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
# 美化
sudo pacman -S fortune-mod cowsay lolcat fastfetch
sudo pacman -S exa zoxide
```

### 终端 / 桌面

```bash
sudo pacman -S kitty tmux mako hyprland
# tmux 插件管理器
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect
git clone https://github.com/dracula/tmux ~/.tmux/plugins/dracula
```

### 编辑器

```bash
sudo pacman -S neovim
# 字体
sudo pacman -S noto-fonts noto-fonts-cjk ttf-jetbrains-mono-nerd
```

### 输入法

```bash
sudo pacman -S fcitx5 fcitx5-chinese-addons fcitx5-configtool
```

### 文件管理 / 其他

```bash
sudo pacman -S ranger yazi btop
```

### 桌面系统
常用kde,系统通知使用mako  
字体:Noto Sans Mono,JetBrainsMono Nerd Font,Misans 


### 输入法
使用fcitx5，主题 `blog-dark`（Tokyo Night 毛玻璃暗色，位于 `fcitx5/` 包）


### shell
统一主题dracula & tokyonight  
使用oh-my-zsh+p10k,终端模拟器使用kitty  

### tmux多窗口管理   
![image](https://github.com/user-attachments/assets/55f1aab9-9410-4d43-baa1-43b8adfee067)


### editor
neovim lazyvim管理  
antigravity for vibe coding  
<img width="2559" height="1525" alt="image" src="https://github.com/user-attachments/assets/66219859-57b6-4cb9-ba96-98dc43703fc5" />

<img width="2560" height="533" alt="image" src="https://github.com/user-attachments/assets/00cf4ff4-967d-4332-902b-11a197449254" />


### 常用软件
wps替代microsoft office on windows  
draw.io——绘制图像  
drawpen——快速调出画笔批注  
goldendict——字典  
IMHEX——类010editor  
yazi——文件管理    
btop——进程管理  
virtual manager+qemu/kvm ——虚拟机  
codesnap——代码截图  
VLC——视频  

### music
go-musicfox


## license
- MIT
