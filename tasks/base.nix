{ baseTasks, ... }:
{
  inherit (baseTasks)
    lint_bash
    lint_commits
    lint_nix
    lint_nix-bash
    ;
}
