{ config, pkgs, lib, ... }:

{
  home.activation.mkCodeServerDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p /home/christopher/.code-server
    mkdir -p /home/christopher/projects
    chown -R 1000:100 /home/christopher/.code-server
    chown 1000:100 /home/christopher/projects
  '';

  systemd.user.services.code-server = {
    Unit = {
      Description = "code-server (local binary, user service)";
    };
    Service = {
      # Load environment variables from secrets file
      ExecStartPre = ''
        ${pkgs.bash}/bin/bash -c 'set -a; source /var/lib/secrets.env; set +a'
      '';
      ExecStart = ''
        /home/christopher/.local/bin/code-server --bind-addr 127.0.0.1:8443 --user-data-dir /home/christopher/.code-server/data --config /home/christopher/.code-server/config.yaml --extensions-dir /home/christopher/.code-server/extensions /home/christopher/projects
      '';
      # Ensure environment variables from secrets file are loaded
      EnvironmentFile = "/var/lib/secrets.env";
      Environment = "SHELL=${pkgs.fish}/bin/fish";
      Restart = "always";
      RestartSec = 10;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
