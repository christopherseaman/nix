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
      Description = "code-server (rootless Docker, user service, custom image)";
      After = [ "docker.service" "docker.socket" ];
    };
    Service = {
      ExecStartPre = ''
        ${pkgs.docker}/bin/docker rm -f code-server || true
        ${pkgs.docker}/bin/docker pull sqrlly/code-server:4.99.3
      '';
      ExecStart = ''
        ${pkgs.docker}/bin/docker run --rm \
          --name code-server \
          -p 127.0.0.1:8443:8443 \
          -e PUID=1000 \
          -e PGID=100 \
          -e TZ=${config.home.time.timeZone or "UTC"} \
          -e DEFAULT_WORKSPACE=/config/workspace \
          -e SHELL=${pkgs.fish}/bin/fish \
          --env-file /var/lib/secrets.env \
          -v /home/christopher/.code-server:/config \
          -v /home/christopher/projects:/config/workspace \
          sqrlly/code-server:4.99.3
      '';
      Restart = "always";
      RestartSec = 10;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

