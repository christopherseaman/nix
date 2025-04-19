{ config, pkgs, ... }: {
  virtualisation.oci-containers.containers = {
    openvscode = {
      image = "ghcr.io/linuxserver/openvscode-server:latest";
      ports = ["127.0.0.1:3000:3000"];
      environment = {
        PUID = toString config.users.users.christopher.uid;
        PGID = toString config.users.groups.users.gid;
        TZ = config.time.timeZone;
        
        # Authentication settings
        PASSWORD_FILE = "/config/.password";
        
        # Development environment
        DEFAULT_WORKSPACE = "/projects";
      };
      volumes = [
        "/home/christopher/.openvscode:/config"
        "/home/christopher/projects:/projects"
        "/nix:/nix:ro"
        "/etc/nix:/etc/nix:ro"
        "/run/current-system:/run/current-system:ro"
        "/home/christopher/.ssh:/config/.ssh:ro"
        "/home/christopher/.gitconfig:/config/.gitconfig:ro"
        "/etc/nixos:/config/nixos-config:ro"
      ];
      environmentFiles = [
        "/var/lib/private/secrets.env"
      ];
      extraOptions = [
        "--security-opt=seccomp=unconfined"
      ];
      autoStart = true;
    };
  };

  # Make sure Docker is enabled
  assertions = [{
    assertion = config.virtualisation.docker.enable;
    message = "Docker must be enabled for OpenVSCode Server container";
  }];

  # Setup directories and create password file from secrets
  system.activationScripts.mkOpenVSCodeDirs = ''
    mkdir -p /home/christopher/.openvscode
    mkdir -p /home/christopher/projects
    
    # Create password file from CODESERVER_PASSWORD in secrets.env
    if [ -f /var/lib/private/secrets.env ]; then
      PASSWORD=$(grep "CODESERVER_PASSWORD" /var/lib/private/secrets.env | cut -d'=' -f2)
      echo "$PASSWORD" > /home/christopher/.openvscode/.password
      chmod 600 /home/christopher/.openvscode/.password
    fi
    
    # Set proper permissions
    chown -R christopher:users /home/christopher/.openvscode
    chown christopher:users /home/christopher/projects
    echo "OpenVSCode Server directories prepared"
  '';
}
