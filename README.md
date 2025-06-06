# nan0in_dotfiles
nan0in's dotfiles from his arch-linux,keep exploring  
我使用[GNU Stow](https://www.gnu.org/software/stow/)来帮助我管理我的linux配置文件
简单讲一下Gnu Stow，实际上就是通过两个文件夹来管理文件  
- `stow dir`：默认的当前文件夹
- `target dir`：默认当前文件夹的父文件夹  
那么由此可知`stow dir`下的每一个顶层的子文件夹会是一个单独文件树，而`target dir`下多个这样的文件树会通过同一个起始路径层叠展开，我们 *符号链接* 就可以将文件树指引构建起来

## 探索和收集配置文件
如果你是第一次收集配置文件（在写这个文档的时候我也是），就推荐使用`--adopt`转移一系列的配置文件，参考[chaneyzorn](https://github.com/chaneyzorn/dotfiles?tab=readme-ov-file)的方法你就可以轻松实现一系列dotfiles的构建啦。  
1. 在home目录下创建`stow dir`，我的是`nan0in_dotfiles`
2. 在`stow dir`下分类创建配置文件的文件夹，如`nan0in_dotfiles/zsh`
3. 在`zsh`文件夹下创建对应配置文件或文件夹
4. 在`stow dir`下`stow --adopt zsh`便会对比`target dir`和真实的zsh目录结构并将同树结构的文件引入到`stow dir`，也就是.zshrc会移动过来进行覆盖，在我们的真实目录（HOME .config等等）便会创建符号链接指向转移过来的配置文件
然后我们就可以如法炮制进行添加

### 管理
使用git进行管理，既方便管理也方便在另外的电脑上配置，一些关于`stow dir`的操作如下：  
- `-d`指定stow文件夹
- `-t`指定target文件夹
- `-D`移除已创建的文件树
- `-S`创建指定文件树
- `-R`移除并重新创建指定文件树  
注意了当文件存在发生冲突，一可以删掉已存在文件，二可以`--adopt`选项+git操作将已存在配置文件移动到已在git管理下的`stow dir`选择性操作文件，git commit并checkout

### 桌面系统
有hyprland的但还没完全配置好，常用kde,系统通知使用mako

### 依赖
`.zshrc`中引入了uv管理，安装uv，还有conda

### 输入法
使用fcitx5

### shell
zsh,终端模拟器为konsole
tmux多窗口管理

### editor
neovim lazyvim管理

### 办公文件
libreoffice替代microsoft office on windows

### music
yesplaymusic

## license
- MIT
