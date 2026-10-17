{ pkgs, mkTask, ... }:
{
  diagrams = mkTask {
    description = "Combine every diagram in data/ into data/_all_diagrams.md";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      gnused
    ];
    run = ''
      file=data/_all_diagrams.md
      echo "# All Diagrams" >"$file"
      find data ! -name '_*' -type f | sort | xargs cat >>"$file"
      sed -i '/^$/N;/^\n$/D' "$file"
    '';
  };
}
