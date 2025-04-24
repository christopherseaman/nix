{ config, pkgs, lib, ... }:

let
  commonPackages = import ./common-packages.nix { inherit pkgs; };
  codeServerBase = pkgs.dockerTools.pullImage {
    imageName = "linuxserver/code-server";
    imageDigest = "sha256:72b01086e93a4bab68137159a4f3163446f12da1d892732e2248c007610e85a6";
    sha256 = "quQmoLstCpBxOJJYWaEwVbkJbFP6kFBHyuR9CV3/ZNc=";
    finalImageName = "linuxserver/code-server";
    finalImageTag = "4.99.3";
  };
  customCodeServerImage = pkgs.dockerTools.buildImage {
    name = "sqrlly-code-server";
    tag = "4.99.3";
    fromImage = codeServerBase;
    copyToRoot = pkgs.buildEnv {
      name = "code-server-extra";
      paths = commonPackages;
    };
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
          --user 1000:100 \
          --name code-server \
          -p 127.0.0.1:8443:8443 \
          -e PUID=1000 \
          -e PGID=100 \
          -e TZ=${config.home.time.timeZone or "UTC"} \
          -e DEFAULT_WORKSPACE=/config/workspace \
          -e SHELL=${pkgs.fish}/bin/fish \
          -e PATH=/code-server-extra/bin:$PATH \
          --env-file /var/lib/private/secrets.env \
          -v /home/christopher/.code-server:/config \
          -v /home/christopher/projects:/config/workspace \
          sqrlly-code-server:4.99.3 \
          sh -c '${pkgs.git}/bin/git config --global user.name "Christopher Seaman" && \
                 ${pkgs.git}/bin/git config --global user.email "86775+christopherseaman@users.noreply.github.com" && \
                 exec code-server'
      '';
      Restart = "always";
      RestartSec = 10;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

