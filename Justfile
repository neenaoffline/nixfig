default: stow

stow: stow-dotfiles

stow-dotfiles:
  #!/usr/bin/env bash
  set -euo pipefail
  # Find and backup any conflicting files
  for file in $(cd dotfiles && find . -type f -o -type l | sed 's|^\./||'); do
    target="$HOME/$file"
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo "Backing up $target to $target.backup"
      mv "$target" "$target.backup"
    fi
  done
  stow -vvt ~ dotfiles
