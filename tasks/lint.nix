{ pkgs, mkTask, tasks, ... }:
{
  lint_yaml = mkTask {
    description = "Lint YAML files with yamllint";
    runtimeInputs = [ pkgs.yamllint ];
    run = ''
      yamllint --strict .
      echo "✅ YAML linter passed"
    '';
  };

  lint = mkTask {
    description = "Run all linters";
    runtimeInputs = with tasks; [
      lint_nix.app
      lint_bash.app
      lint_yaml.app
    ];
    run = ''
      lint_nix
      lint_bash
      lint_yaml
    '';
  };
}
