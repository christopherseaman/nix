{ config, pkgs, ... }: {
  virtualisation.oci-containers.containers = {
    code-server = {
      image = "linuxserver/code-server:latest";
      ports = ["127.0.0.1:8443:8443"];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = config.time.timeZone;
        SUDO_PASSWORD = "def";
        DEFAULT_WORKSPACE = "/config/workspace";
        SSH_AUTH_SOCK = "/config/ssh-agent.sock";
      };
      volumes = [
        "/home/christopher/.code-server:/config"
        "/home/christopher/projects:/config/workspace"
        "/nix:/nix:ro"
        "/etc/nix:/etc/nix:ro"
        "/run/current-system:/run/current-system:ro"
        "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        "/nix/var/nix/profiles:/nix/var/nix/profiles:ro"
        "/etc/resolv.conf:/etc/resolv.conf:ro"
        "/etc/ssl:/etc/ssl:ro"
        "/run/user/1000/keyring/ssh:/config/ssh-agent.sock:ro"
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

  # Setup directories
  system.activationScripts.mkCodeServerDirs = ''
    mkdir -p /home/christopher/.code-server
    mkdir -p /home/christopher/projects
    
    # Create helper script for installing Nix extensions
    mkdir -p /home/christopher/.code-server/scripts
    cat > /home/christopher/.code-server/scripts/install-nix-extensions.sh << 'EOF'
    #!/bin/bash
    code-server --install-extension jnoortheen.nix-ide
    code-server --install-extension arrterian.nix-env-selector
    echo "Nix extensions installed! Please restart VS Code Server."
    EOF
    chmod +x /home/christopher/.code-server/scripts/install-nix-extensions.sh
    
    # Set proper permissions
    chown -R 1000:100 /home/christopher/.code-server
    chown 1000:100 /home/christopher/projects
  '';
}
