{ config, pkgs, ... }: {
  virtualisation.oci-containers.containers = {
    code-server = {
      image = "linuxserver/code-server:latest";
      ports = ["127.0.0.1:8443:8443"];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = config.time.timeZone;
        DEFAULT_WORKSPACE = "/config/workspace";
        # Add fish to the mods
        DOCKER_MODS = "linuxserver/mods:code-server-python3|linuxserver/mods:code-server-golang|linuxserver/mods:code-server-nvm|linuxserver/mods:code-server-rust";
      };
      volumes = [
        "/home/christopher/.code-server:/config"
        "/home/christopher/projects:/config/workspace"
      ];
      environmentFiles = [
        "/var/lib/private/secrets.env" # Contains PASSWORD=yourpassword
      ];
      autoStart = true;
    };
  };

  # Ensure the basic directories exist
  system.activationScripts.mkCodeServerDirs = ''
    mkdir -p /home/christopher/.code-server
    mkdir -p /home/christopher/projects
    EOF
    
    # Set proper permissions
    chown -R 1000:100 /home/christopher/.code-server
    chown 1000:100 /home/christopher/projects
  '';
}
