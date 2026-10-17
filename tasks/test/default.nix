{ pkgs, mkTask, ... }:
{
  test = mkTask {
    description = "Run the plugin tests in the test containers";
    runtimeInputs = with pkgs; [
      coreutils
      docker-client
      gnugrep
    ];
    args = {
      down = {
        description = "Stop the test containers once the tests have run";
        type = "flag";
        short = "d";
      };
    };
    run = builtins.readFile ./test.sh;
  };

  test_ci = mkTask {
    description = "Run the plugin tests in fresh containers (CI)";
    runtimeInputs = [ pkgs.docker-client ];
    run = builtins.readFile ./test-ci.sh;
  };
}
