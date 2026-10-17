{
  pkgs,
  lib,
  mkTask,
  baseTasks,
  ...
}:
let
  base = baseTasks.release;
in
{
  release = mkTask {
    description = "Publish a GitHub release with git-cliff notes and the plugin archive for the current tag";
    inherit (base) args;
    runtimeInputs = with pkgs; [
      coreutils
      gh
      git
      zip
    ];
    run = ''
      tag="''${GITHUB_REF_NAME:-$(git describe --tags --exact-match HEAD 2>/dev/null || true)}"
      archive=redmine_kroki.zip
      tmp=$(mktemp -d)
      trap 'rm -rf "$tmp"' EXIT

      cp -r src "$tmp/redmine_kroki"
      rm -rf "$tmp/redmine_kroki/test"
      (cd "$tmp" && zip -qr "$archive" redmine_kroki)

      flags=()
      if [ "$dry_run" = true ]; then
        flags+=(--dry-run)
      fi
      ${lib.getExe base.app} "''${flags[@]}"

      if [ "$dry_run" = true ]; then
        info "Would upload $archive ($(du -h "$tmp/$archive" | cut -f1)) to release $tag"
        exit 0
      fi

      gh release upload "$tag" "$tmp/$archive"
      info "Uploaded $archive to release $tag"
    '';
  };
}
