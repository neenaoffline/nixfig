{
  description = "Dev shell with everything to run things here";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    aider-nix.url = "github:matko/aider-nix";
    nvf.url = "github:notashelf/nvf";

  };

  outputs = inputs@{ flake-parts, self, nixpkgs, nvf, aider-nix } : flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    perSystem = { pkgs, self', inputs', ... }: 
      let
        pi-coding-agent = pkgs.buildNpmPackage {
          pname = "pi-coding-agent";
          version = "0.42.2";

          src = pkgs.fetchurl {
            url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-0.42.2.tgz";
            hash = "sha256-t4T8v6ggONtAUo+NnJ15MXe/cn2u/8f9VUziHJQ9cVc=";
          };

          sourceRoot = "package";

          postPatch = ''
            cp ${./package-lock.json} package-lock.json
          '';

          dontNpmBuild = true;

          npmDepsHash = "sha256-BRfSWwR2BX6RmgCDihVcvTWokoxdWNVgbrCAcCEJPkw=";

          meta = with pkgs.lib; {
            description = "Coding agent CLI with read, bash, edit, write tools and session management";
            homepage = "https://github.com/badlogic/pi-mono";
            license = licenses.mit;
            mainProgram = "pi";
          };
        };
      in
      {
        packages.zellij = pkgs.zellij;
        packages.pi-coding-agent = pi-coding-agent;
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
            pkgs.irssi
            pkgs.fd
            pkgs.bat
            pkgs.ripgrep
            pkgs.eza
            pkgs.git
            pkgs.zoxide

            pkgs.nixfmt-rfc-style
            self'.packages.neovim
            pi-coding-agent
          ];
        };
      };
  };
}
