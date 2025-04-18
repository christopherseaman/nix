# code-server.nix for shared dirs with host
{ config, pkgs, ... }: {
  # Ensure docker is enabled
  assertions = [{
    assertion = config.virtualisation.docker.enable;
    message = "Docker must be enabled for code-server container";
  }];

  # Define the container
  virtualisation.oci-containers.containers = {
    code-server = {
      image = "linuxserver/code-server:latest";
      ports = ["127.0.0.1:8443:8443"];
      environment = {
        PUID = toString config.users.users.christopher.uid;  # Dynamic UID
        PGID = toString config.users.groups.users.gid;       # Dynamic GID
        TZ = config.time.timeZone;                           # Use system timezone
      };
      volumes = [
        "/home/christopher/.code-server/config:/config"
        "/home/christopher/projects:/home/coder/projects"
        # Additional useful mounts
        "/home/christopher/.ssh:/home/coder/.ssh:ro"         # Share SSH keys (read-only)
        "/home/christopher/.gitconfig:/home/coder/.gitconfig:ro" # Share git config
        "/etc/nixos:/home/coder/nixos-config:ro"             # Access NixOS config
      ];
      environmentFiles = [
        "/var/lib/private/secrets.env"
      ];
      extraOptions = [
        "--network=host"           # Optional: simplifies network access
        "--restart=unless-stopped" # Restart policy
      ];
      autoStart = true;
    };
  };

  # Create necessary directories and set permissions
  system.activationScripts.mkCodeServerDirs = ''
    mkdir -p /home/christopher/.code-server/config
    mkdir -p /home/christopher/projects
    
    # Fix permissions
    chown -R christopher:users /home/christopher/.code-server
    chown -R christopher:users /home/christopher/projects
    
    # Optional: Set sticky bit to maintain ownership on new files
    chmod g+s /home/christopher/projects
  '';
  
  # Add a convenient environment variable for VS Code
  environment.variables = {
    VSCODE_PROJECTS = "/home/christopher/projects";
  };
  
  # Optional: Configure SSH for Git integration
  services.openssh.enable = true;
  
  # Ensure Git is available in the host system
  environment.systemPackages = with pkgs; [
    git
    git-lfs
  ];
}
