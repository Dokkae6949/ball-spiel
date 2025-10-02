{
  description = "Development environment for Godot";

  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    
    flake-parts.url = "github:hercules-ci/flake-parts";

    godot.url = "github:florianvazelle/godot-overlay";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = { system, pkgs, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;

          config = {
            allowUnfree = true;
          };
        };

        devShells.default = pkgs.mkShell {
          name = "godot";

          nativeBuildInputs = with pkgs; [
            inputs.godot.packages."${system}".latest
          ];
        };
      };
    };
}
