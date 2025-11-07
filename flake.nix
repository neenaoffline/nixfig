{
  description = "Dev shell with everything to run things here";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = inputs@{ flake-parts, self, nixpkgs, nvf } : flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    perSystem = { pkgs, self', ... }: {
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
          pkgs.just
          pkgs.stow
          pkgs.zellij
          pkgs.nixfmt-rfc-style
          self'.packages.neovim
	];
      };
    };
  };
}
