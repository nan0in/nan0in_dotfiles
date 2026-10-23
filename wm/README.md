# Window manager / 桌面 Shell

- `ambxst/`：保留的 Hyprland/Ambxst 源码包，`install.sh stow ambxst` 仍使用原包名。
- `niri-edge/`：私有 compositor 的固定来源、构建与回退；保留系统 niri 和正常登录入口。
- `clavis/`：niri + Clavis 源码、配置模板和中文指南；安装入口是仓库根目录的 `scripts/setup-clavis.sh`。

Clavis/Ambxst 是运行在 compositor 上的桌面 Shell，并非替换 niri/Hyprland 的窗口管理器。
统一放在 `wm/` 便于维护，不改变 `~/.local/src/{clavis,ambxst}` 对外路径。
已有 `config/.config/hypr/`、`config/.config/ambxst/` 仍由 `config` 包管理，避免重新部署个人配置。

独立 fork（包含完整修改点、参考和原项目）：

- [nan0in-ambxst](https://github.com/nan0in/nan0in-ambxst) — 基于 [Axenide/Ambxst](https://github.com/Axenide/Ambxst)
- [nan0in-niri-edge](https://github.com/nan0in/nan0in-niri-edge) — 基于 [StatIndet/niri-edge](https://github.com/StatIndet/niri-edge)

Clavis 的运行配置是 **真实可写目录** `~/.config/niri-clavis/`，不是源码目录的软链接。
源模板和运行配置有意分离；安装会更新尚未本地修改的已管理文件，保留个人覆盖和 UI 数据。
详见 [完整入门](clavis/docs/START-HERE.md)、[配置规则](clavis/docs/CONFIGURATION.md)。
