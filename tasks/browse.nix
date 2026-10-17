{ mkTask, baseTasks, ... }:
let
  base = baseTasks.browse;
in
{
  browse = mkTask {
    description = "Open Redmine in your browser (5, 6 or any URL)";
    inherit (base) runtimeInputs run;
    args = base.args // {
      url = base.args.url // {
        description = "Redmine version (5 or 6) or any URL";
        required = false;
        default = "http://localhost:8086";
        aliases = {
          "5" = "http://localhost:8085";
          "6" = "http://localhost:8086";
        };
      };
    };
  };
}
