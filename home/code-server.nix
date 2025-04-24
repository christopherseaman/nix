{ config, pkgs, ... }:

let
  commonPackages = import ./common-packages.nix { inherit pkgs; };
  customCodeServerImage = pkgs.dockerTools.buildImage {
    name = "sqrlly-code-server";
    tag = "4.99.3";
    fromImage = "docker://linuxserver/code-server:4.99.3";
    copyToRoot = pkgs.buildEnv {
      name = "code-server-extra";
      paths = commonPackages;
    };
    extraCommands = ''
      echo ${pkgs.fish}/bin/fish >> /etc/shells
      git config --system user.name "Christopher Seaman"
      git config --system user.email "86775+christopherseaman@users.noreply.github.com"
    '';
  };
in
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
        ${pkgs.docker}/bin/docker load -i ${customCodeServerImage}
      '';
      ExecStart = ''
        ${pkgs.docker}/bin/docker run --rm \
          --name code-server \
          -p 127.0.0.1:8443:8443 \
          -e PUID=1000 \
          -e PGID=100 \
          -e TZ=${config.home.time.timeZone or "UTC"} \
          -e DEFAULT_WORKSPACE=/config/workspace \
          --env-file /var/lib/private/secrets.env \
          -v /home/christopher/.code-server:/config \
          -v /home/christopher/projects:/config/workspace \
          sqrlly-code-server:4.99.3
      '';
      Restart = "always";
      RestartSec = 10;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
