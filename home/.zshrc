# 美化这里的 piano 是我自己找的字符画
export TERM=xterm-256color
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export PATH="/snap/bin:$PATH"
# uv Python 3.13 as default python3/python
export PATH="$HOME/.local/share/uv/python/cpython-3.13-linux-x86_64-gnu/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.npm-global/bin:$PATH"

if [[ -d "$HOME/.opencode/bin" ]]; then
  export PATH="$HOME/.opencode/bin:$PATH"
fi

if [[ -o interactive && -z "$TMUX" ]] \
  && command -v fastfetch >/dev/null 2>&1 \
  && command -v fortune >/dev/null 2>&1 \
  && command -v cowsay >/dev/null 2>&1 \
  && command -v lolcat >/dev/null 2>&1; then
  cowfile="piano"
  [[ -f "$HOME/piano.cow" ]] && cowfile="$HOME/piano.cow"
  fastfetch --logo none --structure title:os:host:kernel:uptime:shell:terminal:localip:cpu:gpu:colors --data-raw "$(fortune | cowsay -W 30 -f "$cowfile")" | lolcat
  echo "------------------------------------------------------------------------------"
  echo ""
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# extract -- 使用 x 文件名 进行解压
# z -- 快速跳转到上一次文件夹
plugins=(git zsh-syntax-highlighting extract web-search jsontools vi-mode zsh-autosuggestions)
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# open buffer line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# 常规一些配置
export SUDO_EDITOR="nvim"
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="nvim +Man!"
export RANGER_LOAD_DEFAULT_RC=false
export XMODIFIERS="@im=fcitx"
export INPUT_METHOD=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

alias gdb="gdb -q"
alias ran='ranger'
alias vim='nvim'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
elif command -v exa >/dev/null 2>&1; then
  alias ls='exa'
fi

[[ -x "$HOME/tools/Burpsuite/burp/Linux/CN_Burp.sh" ]] && alias burp="$HOME/tools/Burpsuite/burp/Linux/CN_Burp.sh"
if command -v kquitapp5 >/dev/null 2>&1 && command -v kstart5 >/dev/null 2>&1; then
  alias reload_kde="kquitapp5 plasmashell && kstart5 plasmashell"
fi

if command -v yazi >/dev/null 2>&1; then
  yazi() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    if [[ -f "$tmp" ]]; then
      IFS= read -r cwd < "$tmp"
      [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
      rm -f -- "$tmp"
    fi
  }
  alias y='yazi'
fi

MINIFORGE_HOME=""
for candidate in "$HOME/miniforge3" "$HOME/.miniforge3"; do
  if [[ -d "$candidate" ]]; then
    MINIFORGE_HOME="$candidate"
    break
  fi
done

if command -v conda >/dev/null 2>&1; then
  __conda_setup="$(conda shell.zsh hook 2>/dev/null)"
  if [[ $? -eq 0 ]]; then
    eval "$__conda_setup"
  fi
  unset __conda_setup
elif [[ -n "$MINIFORGE_HOME" && -f "$MINIFORGE_HOME/etc/profile.d/conda.sh" ]]; then
  . "$MINIFORGE_HOME/etc/profile.d/conda.sh"
elif [[ -n "$MINIFORGE_HOME" ]]; then
  export PATH="$MINIFORGE_HOME/bin:$PATH"
fi

if command -v uv >/dev/null 2>&1; then
  export UV_CACHE_DIR="$HOME/.cache/uv"
  export UV_CONFIG_HOME="$HOME/.config/uv"
fi

alias uvenv='uv venv'
alias uvinit='uv pip install -e .'
alias uvup='uv pip install --upgrade pip setuptools wheel'

[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
[[ "${OPENAI_API_KEY:-}" == "your-openai-api-key-here" ]] && unset OPENAI_API_KEY

# ---------- some convenient functions for me -------------
export PWN_TOOL_PATH="$HOME/pwn/tools/gen_pwn.py"
exp() {
  python "$PWN_TOOL_PATH" "$@"
}

rm() {
  if echo "$@" | grep -Eq -- '-[a-z]*f.*[a-z]*r|-[a-z]*r.*[a-z]*f'; then
    local targets=()
    local arg
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

pwncp() {
  if [ $# -lt 1 ]; then
    echo "用法:"
    echo "  上传文件: pwncp <本地文件> [远程路径]"
    echo "  下载文件: pwncp -r <远程文件> [本地路径]"
    return 1
  fi

  local remote_host="hacker@dojo.pwn.college"
  local key_path="$HOME/.ssh/key"
  local remote_base="/home/hacker"

  _remote_obs() {
    local p="$1"
    if [[ "$p" == /* || "$p" == ~* ]]; then
      echo "$p"
    else
      p="${p#./}"
      printf "%s/%s" "$remote_base" "$p"
    fi
  }

  if [ "$1" = "-r" ]; then
    if [ $# -lt 2 ]; then
      echo "错误: 缺少远程文件路径"
      return 1
    fi
    local remote_path="$(_remote_obs "$2")"
    local local_path="${3:-.}"
    echo "从 pwn.college 下载 $remote_path 到 $local_path ..."
    scp -i "$key_path" "$remote_host:$remote_path" "$local_path"
  else
    local file="$1"
    local remote_path="$(_remote_obs "$2")"
    if [ ! -f "$file" ]; then
      echo "错误: 文件 '$file' 不存在"
      return 1
    fi
    echo "上传 $file 到 pwn.college..."
    scp -i "$key_path" "$file" "$remote_host:$remote_path"
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

  if [[ -f "$tmp_file" ]]; then
    if command -v wl-copy >/dev/null 2>&1; then
      wl-copy --type image/png < "$tmp_file"
    elif command -v xclip >/dev/null 2>&1; then
      xclip -selection clipboard -t image/png -i "$tmp_file"
    else
      echo "没有可用的图片剪贴板命令，文件保留在: $tmp_file"
      return 1
    fi
    rm "$tmp_file"
    print -P "%F{green}✔ Snapshot copied to clipboard!%f"
  else
    print -P "%F{red}✘ Failed to generate snapshot.%f"
  fi
}

unalias setproxy unsetproxy 2>/dev/null

wsl_host_ip() {
  awk '/^nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null \
    || ip route show default 2>/dev/null | awk '{print $3; exit}'
}

setproxy() {
  local host="${1:-$(wsl_host_ip)}"
  if [[ -z "$host" ]]; then
    echo "Failed to detect WSL host IP"
    return 1
  fi

  echo "Set proxy successfully: ${host}:30000"
}

unsetproxy() {
  unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
  echo "Unset proxy successfully"
}

[[ -d "$HOME/projects/NJUPA_nan0in/nemu" ]] && export NEMU_HOME="$HOME/projects/NJUPA_nan0in/nemu"
[[ -d "$HOME/projects/NJUPA_nan0in/abstract-machine" ]] && export AM_HOME="$HOME/projects/NJUPA_nan0in/abstract-machine"
[[ -d "$HOME/projects/riscv-lab/difftest" ]] && export RVDIFF_HOME="$HOME/projects/riscv-lab/difftest"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

if command -v mamba >/dev/null 2>&1; then
  export MAMBA_EXE="$(command -v mamba)"
  export MAMBA_ROOT_PREFIX="${MINIFORGE_HOME:-${MAMBA_ROOT_PREFIX:-$HOME/.mamba}}"
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
  else
    alias mamba="$MAMBA_EXE"
  fi
  unset __mamba_setup
fi

# tmux 添加为默认启动项，并保存上次会话回溯
# if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#   exec tmux new-session -A -s main
# fi

if [[ -n $TMUX ]] && command -v kd >/dev/null 2>&1; then
  __kdwithtmuxpopup() {
    tmux display-popup "kd $@"
  }
  alias kd=__kdwithtmuxpopup
fi

export LIBC_DATABASE_PATH="$HOME/.libc-database"

[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
if command -v go >/dev/null 2>&1; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
unset YAZI_ZOXIDE_OPTS
export _ZO_EXCLUDE_DIRS="/mnt:/tmp"

[[ -f "$HOME/.zshrc.secrets" ]] && source "$HOME/.zshrc.secrets"

# === WSL Proxy Control ===
unalias setproxy unsetproxy 2>/dev/null

wsl_host_ip() {
  awk '/^nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null \
    || ip route show default 2>/dev/null | awk '{print $3; exit}'
}

setproxy() {
  local host="${1:-$(wsl_host_ip)}"
  if [[ -z "$host" ]]; then
    echo "Failed to detect WSL host IP"
    return 1
  fi

  export http_proxy="http://${host}:30000"
  export https_proxy="$http_proxy"
  export all_proxy="socks5://${host}:30000"
  export HTTP_PROXY="$http_proxy"
  export HTTPS_PROXY="$https_proxy"
  export ALL_PROXY="$all_proxy"
  export no_proxy="localhost,127.0.0.1,::1"
  export NO_PROXY="$no_proxy"
  echo "Proxy ON: ${host}:30000"
}

unsetproxy() {
  unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY
  echo "Proxy OFF"
}
