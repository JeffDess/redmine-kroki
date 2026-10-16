{
  description = "Redmine-Kroki Plugin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, git-hooks, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      checks.${system}.pre-commit-check = git-hooks.lib.${system}.run {
        src = ./.;
        hooks.convco.enable = true;
      };

      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        packages = with pkgs; [ convco entr ];
      };

      packages.${system} = { inherit (pkgs) convco; };
    };
}
