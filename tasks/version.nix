{
  pkgs,
  lib,
  mkTask,
  baseTasks,
  tasks,
  ...
}:
let
  base = baseTasks.version;
in
{
  version = mkTask {
    description = "Bump the version in flake.nix and src/init.rb, refresh the changelog, commit and tag";
    inherit (base) args;
    runtimeInputs = with pkgs; [
      git
      gnugrep
      gnused
      tasks.lint_commits.app
    ];
    run = ''
      init=src/init.rb

      if [ "$dry_run" != true ] && [ "$(git branch --show-current)" != main ]; then
        error 'Version must be bumped from the main branch'
        exit 1
      fi

      if ! grep -q "^  version '[^']*'$" "$init"; then
        error "Could not find the version line in $init"
        exit 1
      fi

      lint_commits

      flags=()
      if [ "$dry_run" = true ]; then
        flags+=(--dry-run)
      fi
      ${lib.getExe base.app} "''${flags[@]}" ''${level:+"$level"}

      if [ "$dry_run" = true ]; then
        exit 0
      fi

      new=$(sed -n -E 's/^[[:space:]]*version = "([^"]+)";.*/\1/p;T;q' flake.nix)
      sed -i -E "s/^(  version ')[^']+(')$/\1$new\2/" "$init"
      git add "$init"
      git commit --quiet --amend --no-edit
      git tag --force --annotate "v$new" --message "v$new" >/dev/null
      info "Mirrored $new into $init"
    '';
  };
}
