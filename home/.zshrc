#美化这里的piano是我自己找的字符画
fastfetch --logo none --structure title:os:host:kernel:uptime:shell:terminal:localip:cpu:gpu:colors --data-raw "$(fortune | cowsay -W 30 -f piano)" | lolcat
# fastfetch --logo none --data-raw "$(fortune | cowsay -W 30 -f piano)" | lolcat
echo "------------------------------------------------------------------------------"
echo "\n"

# 自己记得改
export XDG_CONFIG_HOME=/home/nan0in27/.config

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

#extract--使用x 文件名 进行解压
#z-- z 文件夹 快速跳转到上一次文件夹

plugins=(z git zsh-syntax-highlighting extract web-search jsontools vi-mode zsh-autosuggestions )

export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source $ZSH/oh-my-zsh.sh


# 常规一些配置
export EDITOR="nvim"          # 默认编辑器设为 Neovim,也是为了yazi配置的
export VISUAL="nvim"          # 图形环境备用编辑器
alias gdb="gdb -q"
alias ran='ranger'
alias vim='nvim'
alias neo='neovide'
alias ls='exa'
alias burp='/home/nan0in27/Burpsuite/burp/Linux/CN_Burp.sh'
alias reload_kde="kquitapp5 plasmashell && kstart5 plasmashell"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/nan0in27/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/nan0in27/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/nan0in27/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/nan0in27/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# ======================
# UV Python 包管理器配置
# ======================

# 确保本地 bin 目录在 PATH 中
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/home/nan0in27/.miniforge3/bin

# 初始化 UV
if command -v uv > /dev/null 2>&1; then
    # 设置 UV 的缓存和配置目录
    export UV_CACHE_DIR="$HOME/.cache/uv"
    export UV_CONFIG_HOME="$HOME/.config/uv"
    
    # 自动激活 UV (如果已安装)
    # eval "$(uv activate zsh)"
    
    # 设置默认 Python 版本 (可选)
    # alias uvpython='uv venv -p python3.11'
fi

# 常用 UV 别名
alias uvenv='uv venv'
alias uvinit='uv pip install -e .'
alias uvup='uv pip install --upgrade pip setuptools wheel'


# 输入法 
export XMODIFIERS="@im=fcitx"
export INPUT_METHOD=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export RANGER_LOAD_DEFAULT_RC=false

. "$HOME/.local/bin/env"

# some convenient fucntions for me 
export PWN_TOOL_PATH="$HOME/pwn/tools/gen_pwn.py"
function exp(){
      python "$PWN_TOOL_PATH" "$@"
}

# exp() {
#     if [ -f "./exp.py" ]; then
#         echo "exp.py already exists in current directory."
#         echo -n "Overwrite? (y/n/rename): "
#         read choice
#         case $choice in
#             y|Y) 
#                 cp ~/pwn/exp.py ./
#                 echo "exp.py overwritten."
#                 ;;
#             n|N) 
#                 echo "Operation cancelled." 
#                 ;;
#             r|R) 
#                 echo -n "Enter new filename: "
#                 read newname
#                 cp ~/pwn/exp.py "./$newname"
#                 echo "Copied to $newname"
#                 ;;
#             *) 
#                 echo "Invalid choice. Operation cancelled." 
#                 ;;
#         esac
#     else
#         cp ~/pwn/exp.py ./
#         echo "exp.py copied to current directory."
#     fi
# }

rm() {
  if echo "$@" | grep -Eq -- '-[a-z]*f.*[a-z]*r|-[a-z]*r.*[a-z]*f'; then
    echo "[🚨警告] 你正在尝试使用 rm -rf，请小心！"
    echo -n "你真的想继续吗？[yes/NO] "
    read answer
    if [[ $answer != "yes" ]]; then
      echo "❎ 已取消 rm -rf。"
      return
    fi
  fi
  echo "[⚠️] 即将删除：$@"
  echo -n "是否继续? [y/N] "
  read ans
  if [[ $ans == [Yy] ]]; then
    command rm "$@"
  else
    echo "❎ 已取消删除。"
  fi
}

# pwncollege file transfer
pwncp() {
    if [ $# -lt 1 ]; then
        echo "用法:"
        echo "  上传文件: pwncp <本地文件> [远程路径]"
        echo "  下载文件: pwncp -r <远程文件> [本地路径]"
        echo ""
        echo "示例:要用绝对路径"
        echo "  pwncp socket.py"
        echo "  pwncp script.py /subfolder/"
        echo "  pwncp -r /remote/file.txt ."
        return 1
    fi

    remote_host="hacker@dojo.pwn.college"
    key_path="$HOME/.ssh/key"  

    if [ "$1" = "-r" ]; then  # ⚠️ 用单等号，zsh 与 bash 兼容
        # 从远程 -> 本地
        if [ $# -lt 2 ]; then
            echo "错误: 缺少远程文件路径"
            return 1
        fi
        remote_file="$2"
        local_path="${3:-.}"  # 默认下载到当前目录
        echo "从 pwn.college 下载 $remote_file 到 $local_path ..."
        scp -i "$key_path" "$remote_host:$remote_file" "$local_path"
        if [ $? -eq 0 ]; then
            echo "✓ 下载成功!"
        else
            echo "✗ 下载失败!"
        fi
    else
        # 本地 -> 远程
        file="$1"
        remote_path="${2:-~}"
        if [ ! -f "$file" ]; then
            echo "错误: 文件 '$file' 不存在"
            return 1
        fi
        echo "上传 $file 到 pwn.college..."
        scp -i "$key_path" "$file" "$remote_host:$remote_path"
        if [ $? -eq 0 ]; then
            echo "✓ 上传成功!"
        else
            echo "✗ 上传失败!"
        fi
    fi
}

gdiff() {
    if [ $# -eq 0 ]; then
        git difftool --tool=nvimdiff
    else
        git difftool --tool=nvimdiff "$@"
    fi
}


# 定义代理地址变量
httpproxy=http://127.0.0.1:20171
socksproxy=socks5://127.0.0.1:20170

# 设置使用代理
alias setproxy="export http_proxy=$httpproxy; export https_proxy=$httpproxy; export all_proxy=$socksproxy; echo 'Set proxy successfully'"

# 设置取消使用代理
alias unsetproxy="unset http_proxy; unset https_proxy; unset all_proxy; echo 'Unset proxy successfully'"

# 南大pa
export NEMU_HOME=/home/nan0in27/projects/NJUPA_nan0in/nemu
export AM_HOME=/home/nan0in27/projects/NJUPA_nan0in/abstract-machine

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE='/home/nan0in27/miniforge3/bin/mamba';
export MAMBA_ROOT_PREFIX='/home/nan0in27/miniforge3';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# man使用nvim阅读
export MANPAGER="nvim +Man!"

# tmux添加为默认启动项，并保存上次会话回溯
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    # 尝试附加到现有会话，如果没有则创建新会话
    exec tmux new-session -A -s main
fi

# 为kd设置tmux适配浮动窗口 pop  
if [[ -n $TMUX ]]; then
    __kdwithtmuxpopup() {
        tmux display-popup "kd $@"
    }
    alias kd=__kdwithtmuxpopup
fi

# 添加cargo到path->rustlings环境
export PATH="$HOME/.cargo/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH
export OPENAI_API_KEY="sk-n9g3akoM0I6T4nFB1HkDnn82ScHEZdbE1iFx2dS5yRR8LfR9"
export LIBC_DATABASE_PATH="$HOME/.libc-database"

# go path
[[ -s "/home/nan0in27/.gvm/scripts/gvm" ]] && source "/home/nan0in27/.gvm/scripts/gvm"
export PATH=$PATH:$(go env GOPATH)/bin

# zoxide 
eval "$(zoxide init zsh)"
unset YAZI_ZOXIDE_OPTS
export _ZO_EXCLUDE_DIRS="/mnt:/tmp"
