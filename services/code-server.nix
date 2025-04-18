{ config, pkgs, ... }: {
  # Ensure docker is enabled
  assertions = [{
    assertion = config.virtualisation.docker.enable;
    message = "Docker must be enabled for code-server container";
  }];

  # Define the container using oci-containers
  virtualisation.oci-containers.containers = {
    code-server = {
      image = "linuxserver/code-server:latest";
      ports = ["127.0.0.1:8443:8443"];
      environment = {
        PUID = toString config.users.users.christopher.uid;
        PGID = toString config.users.groups.users.gid;
        TZ = config.time.timeZone;
        # Don't set DOCKER_USER - it's not working correctly
      };
      volumes = [
        "/home/christopher/.code-server/config:/config"
        "/home/christopher/projects:/home/coder/projects"
        "/home/christopher/.ssh:/home/coder/.ssh:ro"
        "/home/christopher/.gitconfig:/home/coder/.gitconfig:ro"
        "/etc/nixos:/home/coder/nixos-config:ro"
      ];
      environmentFiles = [
        "/var/lib/private/secrets.env"
      ];
      extraOptions = [
        "--network=host"
        "--user=${toString config.users.users.christopher.uid}:${toString config.users.groups.users.gid}"
      ];
      autoStart = true;
    };
  };

  # Customize the systemd service
  systemd.services.docker-code-server = {
    serviceConfig = {
      Restart = "always";
      RestartSec = "10s";
    };
  };

  # Ensure directories exist with proper permissions
  system.activationScripts.mkCodeServerDirs = ''
    # Create all required directories
    mkdir -p /home/christopher/.code-server/config/data/User
    mkdir -p /home/christopher/.code-server/config/extensions
    mkdir -p /home/christopher/projects
    
    # Fix permissions
    chown -R christopher:users /home/christopher/.code-server
    chmod -R 755 /home/christopher/.code-server
    chmod -R 775 /home/christopher/.code-server/config/data
    chmod -R 775 /home/christopher/.code-server/config/extensions
    
    echo "Code-server directories prepared with permissions"
  '';

  environment.variables = {
    VSCODE_PROJECTS = "/home/christopher/projects";
  };
}
