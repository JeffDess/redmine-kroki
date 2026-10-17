{
  pkgs,
  lib,
  mkTask,
  tasks,
  ...
}:
{
  watch = mkTask {
    description = "Rerun the tests whenever a Ruby file in src/ changes";
    runtimeInputs = with pkgs; [
      entr
      findutils
    ];
    run = ''
      find src -name '*.rb' | entr ${lib.getExe tasks.test.app}
    '';
  };
}
