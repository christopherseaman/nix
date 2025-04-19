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
        PUID = "1000";
        PGID = "100";
        TZ = config.time.timeZone;
        # Remove DOCKER_USER
      };
      volumes = [
        "/home/christopher/.code-server/config:/config"
        "/home/christopher/projects:/projects"
        "/home/christopher/.ssh:/home/coder/.ssh:ro"
        "/home/christopher/.gitconfig:/home/coder/.gitconfig:ro"
        "/etc/nixos:/home/coder/nixos-config:ro"
      ];
      environmentFiles = [
        "/var/lib/private/secrets.env"
      ];
      extraOptions = [
        "--network=host"
        # Remove user option - rely on linuxserver init script
      ];
      autoStart = true;
    };
  };

  # Make the needed directories more permissive
  system.activationScripts.mkCodeServerDirs = ''
    # Create all required directories
    mkdir -p /home/christopher/.code-server/config/data/User
    mkdir -p /home/christopher/.code-server/config/extensions
    mkdir -p /home/christopher/projects
    
    # Make directories widely accessible
    chown -R christopher:users /home/christopher/.code-server
    # chmod -R 777 /home/christopher/.code-server # hopefully not needed with PUID/PGID
    
    echo "Code-server directories prepared with full permissions"
  '';

  environment.variables = {
    DEFAULT_WORKSPACE = "/projects";
    VSCODE_PROJECTS = "/home/christopher/projects";
  };
}


