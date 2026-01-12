default: stow

update:
  #!/usr/bin/env bash
  set -euo pipefail
  
  # Update flake inputs
  echo "Updating flake inputs..."
  nix flake update
  
  # Check for pi-coding-agent updates
  echo "Checking for pi-coding-agent updates..."
  CURRENT_VERSION=$(grep 'version = ' flake.nix | head -1 | sed 's/.*"\(.*\)".*/\1/')
  LATEST_VERSION=$(npm view @mariozechner/pi-coding-agent version 2>/dev/null)
  
  if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "Updating pi-coding-agent: $CURRENT_VERSION -> $LATEST_VERSION"
    
    # Get new source hash
    NEW_SRC_HASH=$(nix-prefetch-url "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-${LATEST_VERSION}.tgz" 2>/dev/null)
    NEW_SRC_HASH_SRI=$(nix hash convert --hash-algo sha256 --to sri "$NEW_SRC_HASH")
    
    # Generate new package-lock.json
    TMPDIR=$(mktemp -d)
    curl -sL "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-${LATEST_VERSION}.tgz" | tar xzf - -C "$TMPDIR"
    (cd "$TMPDIR/package" && npm install --package-lock-only 2>/dev/null)
    cp "$TMPDIR/package/package-lock.json" package-lock.json
    rm -rf "$TMPDIR"
    
    # Update version in flake.nix
    sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$LATEST_VERSION\"/" flake.nix
    
    # Update source hash in flake.nix
    CURRENT_SRC_HASH=$(grep -A2 'src = pkgs.fetchurl' flake.nix | grep 'hash = ' | sed 's/.*"\(.*\)".*/\1/')
    sed -i "s|hash = \"$CURRENT_SRC_HASH\"|hash = \"$NEW_SRC_HASH_SRI\"|" flake.nix
    
    # Update URL version
    sed -i "s|pi-coding-agent-$CURRENT_VERSION.tgz|pi-coding-agent-$LATEST_VERSION.tgz|" flake.nix
    
    # Calculate new npmDepsHash (set to empty first to get the correct hash from error)
    sed -i 's/npmDepsHash = "sha256-[^"]*"/npmDepsHash = ""/' flake.nix
    
    echo "Calculating new npmDepsHash (this may take a moment)..."
    NEW_DEPS_HASH=$(nix build .#pi-coding-agent 2>&1 | grep -oP 'got:\s+\Ksha256-[^\s]+' || true)
    
    if [ -n "$NEW_DEPS_HASH" ]; then
      sed -i "s|npmDepsHash = \"\"|npmDepsHash = \"$NEW_DEPS_HASH\"|" flake.nix
      echo "pi-coding-agent updated to $LATEST_VERSION"
    else
      echo "Warning: Could not calculate npmDepsHash automatically. Please run 'nix build .#pi-coding-agent' and update manually."
    fi
  else
    echo "pi-coding-agent is already at latest version ($CURRENT_VERSION)"
  fi
  
  echo "Update complete!"

stow: template stow-dotfiles

template:
  NIXFIG_DIR="$(pwd)" envsubst < dotfiles/.bashconfig/aliases.template > dotfiles/.bashconfig/aliases

stow-dotfiles:
  stow -vvt ~ dotfiles

force: template
  #!/usr/bin/env bash
  # Remove existing symlinks/files that would conflict
  for f in dotfiles/.*; do
    target="$HOME/$(basename "$f")"
    [ -e "$target" ] || [ -L "$target" ] && rm -rf "$target"
  done
  stow -vvt ~ dotfiles
