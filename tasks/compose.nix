{ pkgs, mkTask, ... }:
let
  docker = [ pkgs.docker-client ];
in
{
  build = mkTask {
    description = "Build the development images";
    runtimeInputs = docker;
    run = "docker compose build";
  };

  run = mkTask {
    description = "Start the development environment (Redmine 5 and 6)";
    runtimeInputs = docker;
    run = "docker compose up -d";
  };

  halt = mkTask {
    description = "Stop the development environment";
    runtimeInputs = docker;
    run = "docker compose down";
  };

  restart = mkTask {
    description = "Restart the Redmine containers";
    runtimeInputs = docker;
    run = ''
      docker compose down redmine5 redmine6
      docker compose up -d redmine5 redmine6
    '';
  };
}
