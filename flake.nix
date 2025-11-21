{
  description = "Dev shell with everything to run things here";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    aider-nix.url = "github:matko/aider-nix";
    nvf.url = "github:notashelf/nvf";
    opencode.url = "github:sst/opencode";
  };

  outputs = inputs@{ flake-parts, self, nixpkgs, nvf, aider-nix, opencode } : flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    perSystem = { pkgs, self', inputs', ... }: {
      packages.zellij = pkgs.zellij;
      packages.neovim = let
        configuration = {};

      customNeovim = nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [configuration];
      };
      in
        customNeovim.neovim;

      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.bashInteractive
          pkgs.zig
          pkgs.just
          pkgs.stow
          pkgs.zellij
          pkgs.zed-editor
	  pkgs.irssi
          inputs'.opencode.packages.default
          pkgs.nixfmt-rfc-style
          self'.packages.neovim
        ];
      };
    };
  };
}
