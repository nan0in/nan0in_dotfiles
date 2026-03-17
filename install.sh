#!/usr/bin/env bash
# install.sh — bootstrap nan0in's dotfiles on a new machine rapidly
#
# Usage:
#   install.sh [command] [options]
#
# Run  install.sh help  to see all available commands.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Stow packages that map directly into $HOME (theme/ needs root — handled separately)
ALL_PACKAGES=(config fcitx5 home)

# ── colours ──────────────────────────────────────────────────────────────────
info() { printf '\033[1;34m[info]\033[0m  %s\n' "$*"; }
ok() { printf '\033[1;32m[ok]\033[0m    %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m  %s\n' "$*"; }
die() {
	printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2
	exit 1
}
header() { printf '\033[1;35m%s\033[0m\n' "$*"; }

# ── helpers ──────────────────────────────────────────────────────────────────
DRY_RUN=false
run() {
	if $DRY_RUN; then
		printf '\033[0;90m[dry-run]\033[0m %s\n' "$*"
	else
		"$@"
	fi
}

require_cmd() {
	command -v "$1" &>/dev/null || die "'$1' is not installed. Install it first."
}

stow_pkg() { # stow_pkg <action: --stow|--delete|--restow> <pkg>
	local action=$1 pkg=$2
	if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
		warn "Package '$pkg' not found, skipping."
		return
	fi
	run stow --dir="$DOTFILES_DIR" --target="$HOME" "$action" "$pkg"
}

resolve_packages() { # resolve_packages [pkg ...] → uses ALL_PACKAGES if none given
	if [[ $# -eq 0 ]]; then
		echo "${ALL_PACKAGES[@]}"
	else
		echo "$@"
	fi
}

# ── commands ─────────────────────────────────────────────────────────────────

cmd_help() {
	cat <<'EOF'

  install.sh — nan0in dotfiles manager

  Usage:
    install.sh [command] [options] [packages...]

  Commands:
    install   [pkg...]   Stow packages and set up secrets file (default if no command given)
    stow      [pkg...]   Create symlinks for the given packages (alias: link)
    unstow    [pkg...]   Remove symlinks for the given packages (alias: unlink, remove)
    restow    [pkg...]   Remove and re-create symlinks (useful after restructuring)
    status               Show which packages are currently stowed
    list                 List all available stow packages
    help                 Show this help message

  Packages:
    config   — ~/.config/* (nvim, kitty, ranger, yazi, fontconfig …)
    fcitx5   — fcitx5 theme (blog-dark) and input method config
    home     — ~/.zshrc, ~/.p10k.zsh, tmux config, …
    (theme/ requires root and is managed manually — see README)

  Options:
    --dry-run   Print what would be done without making any changes
    --target DIR  Override stow target directory (default: $HOME)

  Examples:
    install.sh                    # Full install (stow all + secrets)
    install.sh install            # Same as above
    install.sh stow home          # Only stow the 'home' package
    install.sh restow config      # Re-link config after structure changes
    install.sh unstow fcitx5      # Remove fcitx5 symlinks
    install.sh status             # Check what's linked
    install.sh --dry-run install  # Preview full install without touching files

EOF
}

cmd_list() {
	header "Available packages in $DOTFILES_DIR:"
	for pkg in "${ALL_PACKAGES[@]}"; do
		if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
			printf '  \033[1;32m✓\033[0m  %s\n' "$pkg"
		else
			printf '  \033[1;31m✗\033[0m  %s  (directory not found)\n' "$pkg"
		fi
	done
	printf '  \033[0;90m~\033[0m  theme  (root-only, manual install)\n'
}

cmd_status() {
	require_cmd stow
	header "Stow status (target: $HOME):"
	for pkg in "${ALL_PACKAGES[@]}"; do
		[[ ! -d "$DOTFILES_DIR/$pkg" ]] && continue
		# Pick the first tracked file in the package and check if it's a symlink into dotfiles
		local sample
		sample=$(find "$DOTFILES_DIR/$pkg" -not -type d | head -1)
		if [[ -z "$sample" ]]; then
			printf '  \033[0;90m?\033[0m  %s  (empty package)\n' "$pkg"
			continue
		fi
		# Compute relative path from package root
		local rel="${sample#$DOTFILES_DIR/$pkg/}"
		local target_file="$HOME/$rel"
		if [[ -L "$target_file" ]] && [[ "$(readlink -f "$target_file")" == "$(readlink -f "$sample")" ]]; then
			printf '  \033[1;32m✓ stowed  \033[0m  %s\n' "$pkg"
		elif [[ -e "$target_file" ]]; then
			printf '  \033[1;33m~ conflict\033[0m  %s  (%s exists but is not a symlink to dotfiles)\n' "$pkg" "$target_file"
		else
			printf '  \033[1;31m✗ missing \033[0m  %s\n' "$pkg"
		fi
	done
}

cmd_stow() {
	require_cmd stow
	local pkgs
	read -ra pkgs <<<"$(resolve_packages "$@")"
	for pkg in "${pkgs[@]}"; do
		info "Stowing '$pkg'..."
		stow_pkg --stow "$pkg"
		ok "Stowed '$pkg'"
	done
}

cmd_unstow() {
	require_cmd stow
	local pkgs
	read -ra pkgs <<<"$(resolve_packages "$@")"
	for pkg in "${pkgs[@]}"; do
		info "Removing '$pkg' symlinks..."
		stow_pkg --delete "$pkg"
		ok "Removed '$pkg'"
	done
}

cmd_restow() {
	require_cmd stow
	local pkgs
	read -ra pkgs <<<"$(resolve_packages "$@")"
	for pkg in "${pkgs[@]}"; do
		info "Restowing '$pkg'..."
		stow_pkg --restow "$pkg"
		ok "Restowed '$pkg'"
	done
}

cmd_install() {
	require_cmd stow
	require_cmd git

	info "Stow target : $HOME"
	info "Dotfiles dir: $DOTFILES_DIR"
	$DRY_RUN && warn "Dry-run mode — no changes will be made"

	cmd_stow "${ALL_PACKAGES[@]}"

	# ── secrets file ──────────────────────────────────────────────────────────
	local secrets="$HOME/.zshrc.secrets"
	local example="$HOME/.zshrc.secrets.example" # stowed from home/

	if [[ ! -f "$secrets" ]]; then
		if [[ -f "$example" ]]; then
			run cp "$example" "$secrets"
			warn "Created $secrets from example — fill in your API keys!"
		else
			warn "$secrets not found and no example to copy. Create it manually."
		fi
	else
		ok "$secrets already exists, skipping."
	fi

	echo ""
	ok "All done! Open a new shell or run: source ~/.zshrc"
}

# ── argument parsing ──────────────────────────────────────────────────────────
TARGET_OVERRIDE=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
	case "$1" in
	--dry-run)
		DRY_RUN=true
		shift
		;;
	--target)
		TARGET_OVERRIDE="$2"
		shift 2
		;;
	--target=*)
		TARGET_OVERRIDE="${1#--target=}"
		shift
		;;
	--help | -h)
		cmd_help
		exit 0
		;;
	*)
		POSITIONAL+=("$1")
		shift
		;;
	esac
done

[[ -n "$TARGET_OVERRIDE" ]] && HOME="$TARGET_OVERRIDE"

COMMAND="${POSITIONAL[0]:-install}"
ARGS=("${POSITIONAL[@]:1}")

case "$COMMAND" in
install) cmd_install "${ARGS[@]}" ;;
stow | link) cmd_stow "${ARGS[@]}" ;;
unstow | unlink | remove) cmd_unstow "${ARGS[@]}" ;;
restow) cmd_restow "${ARGS[@]}" ;;
status) cmd_status ;;
list) cmd_list ;;
help | --help | -h) cmd_help ;;
*) die "Unknown command '$COMMAND'. Run: install.sh help" ;;
esac
