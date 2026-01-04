default: stow

stow: template stow-dotfiles

template:
  NIXFIG_DIR="$(pwd)" envsubst < dotfiles/.bashconfig/aliases.template > dotfiles/.bashconfig/aliases

stow-dotfiles:
  stow -vvt ~ dotfiles
