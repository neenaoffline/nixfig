
default: stow

stow: stow-dotfiles

stow-dotfiles:
  stow -vvt ~ bash
