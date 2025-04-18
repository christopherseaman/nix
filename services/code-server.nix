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
        # Removed the "--restart=unless-stopped" option
      ];
      autoStart = true;
    };
  };

  # You can customize the systemd service if needed
  systemd.services.docker-code-server = {
    serviceConfig = {
      # These settings override the defaults
      Restart = "always";
      RestartSec = "10s";
    };
  };

  # Rest of your configuration...
  system.activationScripts.mkCodeServerDirs = ''
    mkdir -p /home/christopher/.code-server/config
    mkdir -p /home/christopher/projects
    
    # Fix permissions
    chown -R christopher:users /home/christopher/.code-server
    chown -R christopher:users /home/christopher/projects
    
    # Optional: Set sticky bit to maintain ownership on new files
    chmod g+s /home/christopher/projects
  '';
  
  environment.variables = {
    VSCODE_PROJECTS = "/home/christopher/projects";
  };
}
