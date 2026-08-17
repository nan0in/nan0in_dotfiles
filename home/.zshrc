#美化这里的piano是我自己找的字符画
#
[[ -d "$HOME/.cows" ]] && export COWPATH="$HOME/.cows${COWPATH:+:$COWPATH}"
if (( $+commands[fastfetch] && $+commands[fortune] && $+commands[cowsay] && $+commands[lolcat] )); then
  fastfetch --logo none --structure title:os:host:kernel:uptime:shell:terminal:localip:cpu:gpu:colors --data-raw "$(fortune | cowsay -W 30 -f piano)" | lolcat
fi
# fastfetch --logo none --data-raw "$(fortune | cowsay -W 30 -f piano)" | lolcat
echo "------------------------------------------------------------------------------"
echo "\n"

# 自己记得改
export XDG_CONFIG_HOME=/home/nan0in/.config
export TERM=xterm-256color

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
if [[ -f ~/.p10k.zsh ]] ; then
  source ~/.p10k.zsh
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
#extract--使用x 文件名 进行解压
#z-- z 文件夹 快速跳转到上一次文件夹

plugins=(z git zsh-syntax-highlighting extract web-search jsontools vi-mode zsh-autosuggestions python)

export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# kitty / kitten completion must be on fpath before Oh My Zsh runs compinit.
if [[ -d /usr/lib/kitty/shell-integration/zsh/completions ]]; then
  fpath=(/usr/lib/kitty/shell-integration/zsh/completions $fpath)
fi

[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# open buffer line in editor
autoload -Uz edit-command-line 
zle -N edit-command-line 
bindkey '^X^E' edit-command-line

# 常规一些配置
if (( $+commands[nvim] )); then
  export SUDO_EDITOR="nvim"
  export EDITOR="nvim"          # 默认编辑器设为 Neovim,也是为了yazi配置的
  export VISUAL="nvim"          # 图形环境备用编辑器
  alias vim='nvim'
else
  export SUDO_EDITOR="${EDITOR:-vi}"
  export EDITOR="${EDITOR:-vi}"
  export VISUAL="${VISUAL:-vi}"
fi
alias gdb="gdb -q"
(( $+commands[ranger] )) && alias ran='ranger'
if (( $+commands[eza] )); then
  alias ls='eza'
elif (( $+commands[exa] )); then
  alias ls='exa'
else
  alias ls='ls --color=auto'
fi
alias burp='/home/nan0in/tools/Burpsuite/burp/Linux/CN_Burp.sh'
# alias checksec="/usr/bin/checksec"

# yazi 退出后同步 shell 当前目录
if (( $+commands[yazi] )); then
  yazi() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }

  alias y='yazi'
fi
compdef _kitty kitten
# ======================
# UV Python 环境配置
# ======================

# 确保本地 bin 目录在 PATH 中 (uv tools)
export PATH="$HOME/.local/bin:$PATH"
# UV_PYTHON 不再固定到 ~/.local/bin/python，避免替代系统 python

# AwdPwnPatcher PYTHONPATH
export PYTHONPATH=/home/nan0in/pwn/tools/AwdPwnPatcher:$PYTHONPATH
export PYTHONPATH=/home/nan0in/pwn/tools/Some-of-House:$PYTHONPATH

# UV 配置
export UV_CACHE_DIR="$HOME/.cache/uv"
export UV_CONFIG_HOME="$HOME/.config/uv"
# 常用 UV 别名
alias uvenv='uv venv'
alias uvsync='uv sync'
alias uvadd='uv add'

# 自动激活 base venv (不覆盖已激活的环境)
if [[ -z "$VIRTUAL_ENV" && -f "$HOME/.venvs/base/bin/activate" ]]; then
  source "$HOME/.venvs/base/bin/activate"
fi
alias powerprofilesctl='/usr/bin/python /usr/bin/powerprofilesctl'


# 输入法 
export XMODIFIERS="@im=fcitx"
export INPUT_METHOD=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export RANGER_LOAD_DEFAULT_RC=false

# ~/.local/bin is already added to PATH above. Do not source a user-local
# executable named "env": it can shadow /usr/bin/env for every subprocess.

# ----------some convenient fucntions for me------------- 

rm() {
  if echo "$@" | grep -Eq -- '-[a-z]*f.*[a-z]*r|-[a-z]*r.*[a-z]*f'; then
    local targets=()
    for arg in "$@"; do
      if [[ "$arg" != -* ]]; then
        targets+=("$arg")
      fi
    done

    echo -e "\033[1;31m[🚨警告] 你正在尝试使用 rm -rf！\033[0m"
    echo -e "\033[1;33m待删除的目标对象：\033[0m"
    printf "  - %s\n" "${targets[@]}"
    
    echo -n "确认执行？[y/N] "
    read answer
    
    if [[ ! "$answer" =~ ^[Yy](es)?$ ]]; then
      echo "❎ 操作已终止。"
      return
    fi
  fi

  command rm "$@"
}

# pwncollege file transfer
pwncp() {
    if [ $# -lt 1 ]; then
        echo "用法:"
        echo "  上传文件: pwncp <本地文件> [远程路径]"
        echo "  下载文件: pwncp -r <远程文件> [本地路径]"
        return 1
    fi

    remote_host="hacker@dojo.pwn.college"
    key_path="$HOME/.ssh/key"  
    remote_base="/home/hacker"

    # 把用户输入的远端路径变成绝对路径：
    # - 以 / 开头：认为已经是绝对路径，原样返回
    # - 以 ~ 开头：认为是家目录语义，原样返回（scp 让远端 shell 展开）
    # - 其他：认为是相对 /home/hacker 的路径，自动拼上 remote_base
    _remote_obs(){
      local p="$1" 
      if [[ "$p" == /* || "$p" == ~* ]]; then
        echo "$p"
      else
        p="${p#./}" # 去掉开头的 ./ 
        printf "%s/%s" "$remote_base" "$p"
      fi
    }

    if [ "$1" = "-r" ]; then  # ⚠️ 用单等号，zsh 与 bash 兼容
        # 从远程 -> 本地
        if [ $# -lt 2 ]; then
            echo "错误: 缺少远程文件路径"
            return 1
        fi
        remote_path="$(_remote_obs "$2")" 
        local_path="${3:-.}"  # 默认下载到当前目录
        echo "从 pwn.college 下载 $remote_path 到 $local_path ..."
        scp -i "$key_path" "$remote_host:$remote_path" "$local_path"
        if [ $? -eq 0 ]; then
            echo "✓ 下载成功!"
        else
            echo "✗ 下载失败!"
        fi
    else
        # 本地 -> 远程
        file="$1"
        remote_path="$(_remote_obs "$2")"  
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

snap-copy() {
    local tmp_file="/tmp/codesnap_$(date +%s).png"
    codesnap "$@" --output "$tmp_file"

    # 检查文件是否生成成功
    if [[ -f "$tmp_file" ]]; then
        # --type image/png 明确告诉 KDE 这是图片
        wl-copy --type image/png < "$tmp_file"
        # 清理临时文件
        rm "$tmp_file"
        print -P "%F{green}✔ Snapshot copied to KDE clipboard!%f"
    else
        print -P "%F{red}✘ Failed to generate snapshot.%f"
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
export NEMU_HOME=/home/nan0in/projects/NJUPA_nan0in/nemu
export AM_HOME=/home/nan0in/projects/NJUPA_nan0in/abstract-machine

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use --silent default >/dev/null


# ---- TTY 优化：英文 locale + 大字体 ----
if tty | grep -q '/dev/tty[0-9]'; then
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US
    [ -f /usr/share/kbd/consolefonts/sun12x22.psfu.gz ] && setfont sun12x22 >/dev/null
fi

# >>> mamba initialize >>> (DISABLED - migrated to uv)
# To re-enable mamba temporarily, uncomment below:
# export MAMBA_EXE='/home/nan0in/miniforge3/bin/mamba';
# export MAMBA_ROOT_PREFIX='/home/nan0in/miniforge3';
# __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__mamba_setup"
# else
#     alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
# fi
# unset __mamba_setup
# <<< mamba initialize <<<

# man使用nvim阅读
export MANPAGER="nvim +Man!"

# tmux添加为默认启动项，并保存上次会话回溯
# if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
# #    尝试附加到现有会话，如果没有则创建新会话
#    exec tmux new-session -A -s main
# fi

# 为kd设置tmux适配浮动窗口 pop  
if [[ -n $TMUX ]]; then
    __kdwithtmuxpopup() {
        tmux display-popup "kd $@"
    }
    alias kd=__kdwithtmuxpopup
fi

# 添加cargo到path->rustlings环境
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:$HOME/.npm-global/bin"
export LIBC_DATABASE_PATH="$HOME/.libc-database"

# go path
[[ -s "/home/nan0in/.gvm/scripts/gvm" ]] && source "/home/nan0in/.gvm/scripts/gvm"
(( $+commands[go] )) && export PATH=$PATH:$(go env GOPATH)/bin

# zoxide 
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
unset YAZI_ZOXIDE_OPTS
export _ZO_EXCLUDE_DIRS="/mnt:/tmp"
export RVDIFF_HOME=/home/nan0in/projects/riscv-lab/difftest

# source secrets (API keys etc.) — not tracked by git
[[ -f "$HOME/.zshrc.secrets" ]] && source "$HOME/.zshrc.secrets"
export PATH="$HOME/.local/bin:$PATH"

# oslab: fix permissions after Docker build (Docker runs as root, host as nan0in27)
fixoslab() {
    local dir="${1:-/home/nan0in/projects/oslab}"
    docker exec 798c1a238ef9 chown -R 1000:1000 /root/oslab/ 2>/dev/null
    echo "oslab permissions synced"
}


# bun completions
[ -s "/home/nan0in/.bun/_bun" ] && source "/home/nan0in/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# kimi-code
export PATH="/home/nan0in/.kimi-code/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export SUDO_ASKPASS=/usr/bin/ksshaskpass
export SUDO_ASKPASS=/usr/bin/ksshaskpass

# opencode
export PATH=/home/nan0in/.opencode/bin:$PATH
