{
  description = "Dev shell with everything to run things here";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, self, nixpkgs } : flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    perSystem = { pkgs, ... }: {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
	just
	stow
	nixfmt-rfc-style
	];
      };
  };
}
