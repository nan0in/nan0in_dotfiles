#美化这里的piano是我自己找的字符画
fastfetch --logo none --structure title:os:host:kernel:uptime:shell:terminal:localip:disk:cpu:gpu:colors --data-raw "$(fortune | cowsay -W 30 -f piano)" | lolcat
# fastfetch --logo none --data-raw "$(fortune | cowsay -W 30 -f piano)" | lolcat
echo "------------------------------------------------------------------------------"
echo "\n"

# 自己记得改
export XDG_CONFIG_HOME=/home/nan0in27/.config

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

#extract--使用x 文件名 进行解压
#z-- z 文件夹 快速跳转到上一次文件夹

plugins=(git zsh-syntax-highlighting extract web-search jsontools z vi-mode zsh-autosuggestions )


export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source $ZSH/oh-my-zsh.sh


# 常规一些配置
export EDITOR="nvim"          # 默认编辑器设为 Neovim,也是为了yazi配置的
export VISUAL="nvim"          # 图形环境备用编辑器
export YAZI_ZOXIDE_OPTS="--exclude /mnt /tmp"  # zoxide 排除目录（按需修改）


alias ran='ranger'
# alias vim='nvim'
alias vim='nvim'
alias neo='neovide'


#configurations of yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# >>> conda initialize >>>
# !! contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/nan0in27/software/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/nan0in27/software/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/nan0in27/software/anaconda3/etc/profile.d/conda.sh"
    else
        export path="/home/nan0in27/software/anaconda3/bin:$path"
    fi
fi
unset __conda_setup
# # <<< conda initialize <<<
#

# ======================
# UV Python 包管理器配置
# ======================

# 确保本地 bin 目录在 PATH 中
export PATH="$HOME/.local/bin:$PATH"

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


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# shurufa
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export RANGER_LOAD_DEFAULT_RC=false

. "$HOME/.local/bin/env"
source /usr/share/nvm/init-nvm.sh source /usr/share/nvm/init-nvm.sh
source /usr/share/nvm/init-nvm.sh
eval "$(rbenv init -)"



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


# 定义代理地址变量
# httpproxy=http://127.0.0.1:20171
# socksproxy=socks5://127.0.0.1:20170

httpproxy=http://127.0.0.1:7890
socksproxy=socks5://127.0.0.1:7890

# 设置使用代理
alias setproxy="export http_proxy=$httpproxy; export https_proxy=$httpproxy; export all_proxy=$socksproxy; echo 'Set proxy successfully'"

# 设置取消使用代理
alias unsetproxy="unset http_proxy; unset https_proxy; unset all_proxy; echo 'Unset proxy successfully'"

# 查ip
# alias ipcn="curl myip.ipip.net"
# alias ip="curl ip.sb"

# bug 
export PATH="$HOME/.local/bin:$PATH"


# 南大pa
export NEMU_HOME=/home/nan0in27/NJUPA/ics2024/nemu
export AM_HOME=/home/nan0in27/NJUPA/ics2024/abstract-machine
alias gcc='./usr/bin/ccache/gcc'


