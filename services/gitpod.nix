{ config, pkgs, ... }: {
  virtualisation.oci-containers.containers = {
    gitpod = {
      image = "gitpod/openvscode-server:latest";
      ports = ["127.0.0.1:3000:3000"];  # Map directly to port 3000
      environment = {
        OPENVSCODE_SERVER_ROOT = "/home/workspace";
        
        # Token authentication
        OPENVSCODE_SERVER_AUTH = "token";
        
        # User settings
        USER = "workspace";
        PUID = toString config.users.users.christopher.uid;
        PGID = toString config.users.groups.users.gid;
        
        # Development paths
        WORKSPACE_ROOT = "/home/workspace/projects";
      };
      volumes = [
        # Project and configuration data
        "/home/christopher/projects:/home/workspace/projects"
        "/home/christopher/.gitpod:/home/workspace/.gitpod"
        "/home/christopher/.gitpod/tokens:/home/workspace/.openvscode-server/token"
        
        # Nix integration
        "/nix:/nix:ro"
        "/etc/nix:/etc/nix:ro"
        "/run/current-system:/run/current-system:ro"
        
        # SSH and Git configuration
        "/home/christopher/.ssh:/home/workspace/.ssh:ro"
        "/home/christopher/.gitconfig:/home/workspace/.gitconfig:ro"
        "/etc/nixos:/home/workspace/nixos-config:ro"
      ];
      extraOptions = [
        "--network=host"
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

  # Setup directories including token directory
  system.activationScripts.mkGitpodDirs = ''
    mkdir -p /home/christopher/.gitpod/data
    mkdir -p /home/christopher/.gitpod/extensions
    mkdir -p /home/christopher/.gitpod/tokens
    mkdir -p /home/christopher/projects
    chown -R christopher:users /home/christopher/.gitpod
    chmod -R 755 /home/christopher/.gitpod
    chown christopher:users /home/christopher/projects
    echo "Gitpod directories prepared with permissions"
  '';
}
