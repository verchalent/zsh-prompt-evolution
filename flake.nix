{
  description = "Portable shell experience: zsh, starship, zellij, helix, ttt and CLI tools for systems you visit";

  # Pins live in flake.lock. Only bump an input to a revision at least 8 days
  # old (supply-chain cooldown), e.g.:
  #   nix flake lock --override-input nixpkgs github:NixOS/nixpkgs/<rev>
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    ttt = {
      url = "github:eugenioenko/ttt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ttt,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      config = ./config;
    in
    {
      packages = forAllSystems (pkgs: rec {
        zsh-prompt = pkgs.callPackage ./nix/wrapper.nix {
          inherit config;
          ttt = ttt.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
        default = zsh-prompt;
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/zsh-prompt";
        };
      });

      checks = forAllSystems (
        pkgs:
        import ./nix/checks.nix {
          inherit pkgs config;
          zsh-prompt = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        }
      );

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt
            statix
            deadnix
            shellcheck
            taplo
          ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
