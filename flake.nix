{
  description = "Redmine-Kroki Plugin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lets = {
      url = "github:JeffDess/lets?ref=v0.4.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks.follows = "git-hooks";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
      lets,
      ...
    }:
    let
      # NOTE: Bumped by `lets version` along with version in src/init.rb
      version = "0.5.1";
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      letsFlake = lets.lib.mkFlake {
        inherit nixpkgs;
        systems = [ system ];
        tasks = ./tasks;
      };
      lintCommits = pkgs.lib.getExe letsFlake.packages.${system}.lint_commits;
    in
    {
      inherit (letsFlake) apps packages;

      checks.${system} = {
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            convco = {
              enable = true;
              entry = "${lintCommits} --allow-fixup --message-file";
            };
            convco-push = {
              enable = true;
              name = "convco (push)";
              stages = [ "pre-push" ];
              pass_filenames = false;
              always_run = true;
              entry = "${lintCommits} --protect main";
            };
          };
        };

        version-sync = pkgs.runCommand "version-sync" { } ''
          grep -q "^  version '${version}'$" ${./src/init.rb}
          touch "$out"
        '';
      };

      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        inputsFrom = [ letsFlake.devShells.${system}.lets ];
      };
    };
}
