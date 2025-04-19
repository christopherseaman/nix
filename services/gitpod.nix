{ config, pkgs, ... }: {
  virtualisation.oci-containers.containers = {
    gitpod = {
      # Use the specific image tag rather than latest
      image = "gitpod/openvscode-server:1.85.0";
      
      # Use regular port mapping without host network
      ports = ["127.0.0.1:3000:3000"];
      
      environment = {
        # Correct environment variables for this container
        HOME = "/home/openvscode-server";
        USER = "openvscode-server";
        OPENVSCODE_SERVER_PORT = "3000";
        
        # Auth settings
        OPENVSCODE_SERVER_AUTH = "token";
        
        # User settings - remove PUID/PGID as they're not supported
        # in this container (it's not a LinuxServer.io container)
      };
      
      volumes = [
        # Project and configuration data
        "/home/christopher/projects:/home/workspace/projects"
        "/home/christopher/.gitpod:/home/openvscode-server/data"
        
        # Nix integration
        "/nix:/nix:ro"
        "/etc/nix:/etc/nix:ro"
        "/run/current-system:/run/current-system:ro"
        
        # SSH and Git configuration
        "/home/christopher/.ssh:/home/openvscode-server/.ssh:ro"
        "/home/christopher/.gitconfig:/home/openvscode-server/.gitconfig:ro"
        "/etc/nixos:/home/workspace/nixos-config:ro"
      ];
      
      # Remove host network mode as it's causing issues
      extraOptions = [
        "--security-opt=seccomp=unconfined"
      ];
      
      autoStart = true;
    };
  };

  # Make sure Docker is enabled
  assertions = [{
    assertion = config.virtualisation.docker.enable;
    message = "Docker must be enabled for Gitpod container";
  }];

  # Setup directories
  system.activationScripts.mkGitpodDirs = ''
    mkdir -p /home/christopher/.gitpod/extensions
    mkdir -p /home/christopher/.gitpod/data
    mkdir -p /home/christopher/projects
    chown -R christopher:users /home/christopher/.gitpod
    chmod -R 755 /home/christopher/.gitpod
    chown christopher:users /home/christopher/projects
    echo "Gitpod directories prepared with permissions"
  '';
}
