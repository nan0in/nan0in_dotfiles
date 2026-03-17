#!/usr/bin/env bash
# install.sh — bootstrap nan0in dotfiles on a new machine
# Usage: bash install.sh [--dry-run]
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

info() { printf '\033[1;34m[info]\033[0m  %s\n' "$*"; }
ok() { printf '\033[1;32m[ok]\033[0m    %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m  %s\n' "$*"; }
die() {
	printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2
	exit 1
}

run() {
	if $DRY_RUN; then
		printf '\033[0;90m[dry-run]\033[0m %s\n' "$*"
	else
		"$@"
	fi
}

# ── dependency check ──────────────────────────────────────────────────────────
for cmd in stow git; do
	command -v "$cmd" &>/dev/null || die "'$cmd' is not installed. Install it first."
done

# ── stow packages ─────────────────────────────────────────────────────────────
# 'theme' requires root and manual placement — skip it here.
PACKAGES=(config fcitx5 home)

info "Stow target: $HOME"
info "Dotfiles dir: $DOTFILES_DIR"
$DRY_RUN && warn "Dry-run mode — no changes will be made"

for pkg in "${PACKAGES[@]}"; do
	if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
		warn "Package '$pkg' not found, skipping."
		continue
	fi
	info "Stowing '$pkg'..."
	run stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg"
	ok "Stowed '$pkg'"
done

# ── secrets file ──────────────────────────────────────────────────────────────
SECRETS="$HOME/.zshrc.secrets"
EXAMPLE="$HOME/.zshrc.secrets.example" # stowed from home/

if [[ ! -f "$SECRETS" ]]; then
	if [[ -f "$EXAMPLE" ]]; then
		run cp "$EXAMPLE" "$SECRETS"
		warn "Created $SECRETS from example — fill in your API keys!"
	else
		warn "$SECRETS not found and no example to copy. Create it manually."
	fi
else
	ok "$SECRETS already exists, skipping."
fi

# ── done ──────────────────────────────────────────────────────────────────────
echo ""
ok "All done! Open a new shell or run: source ~/.zshrc"
