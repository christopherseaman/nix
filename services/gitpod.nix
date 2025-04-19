{ config, pkgs, ... }: {
  virtualisation.oci-containers.containers = {
    openvscode = {
      image = "ghcr.io/linuxserver/openvscode-server:latest";
      ports = ["127.0.0.1:3000:3000"];
      environment = {
        # User IDs
        PUID = "1000";  # Your uid
        PGID = "100";   # Your gid
        TZ = config.time.timeZone;
        
        # Authentication settings
        PASSWORD_FILE = "/config/.password";
        
        # Development environment
        DEFAULT_WORKSPACE = "/projects";
        
        # Nix integration - update PATH to include Nix binaries
        PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
        
        # Nix environment variables
        NIX_REMOTE = "daemon";
        NIX_PATH = "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels";
        NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      };
      volumes = [
        # Writeable volumes
        "/home/christopher/.openvscode:/config"
        "/home/christopher/projects:/projects"
        
        # Nix integration
        "/nix:/nix:ro"
        "/etc/nix:/etc/nix:ro"
        "/run/current-system:/run/current-system:ro"
        "/etc/passwd:/etc/passwd:ro"
        "/etc/group:/etc/group:ro"
        "/etc/resolv.conf:/etc/resolv.conf:ro"
        "/etc/ssl:/etc/ssl:ro"
        
        # Make nix-daemon socket available
        "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        
        # Nix store profiles
        "/nix/var/nix/profiles:/nix/var/nix/profiles:ro"
        
        # SSH and Git configuration
        "/home/christopher/.ssh:/config/.ssh:ro"
        "/home/christopher/.gitconfig:/config/.gitconfig:ro"
        "/etc/nixos:/config/nixos-config:ro"
      ];
      environmentFiles = [
        "/var/lib/private/secrets.env"
      ];
      extraOptions = [
        "--security-opt=seccomp=unconfined"
        "--ipc=host"
      ];
      autoStart = true;
    };
  };

  # Setup directories
  system.activationScripts.mkOpenVSCodeDirs = ''
    mkdir -p /home/christopher/.openvscode
    mkdir -p /home/christopher/projects
    
    # Create password file from CODESERVER_PASSWORD in secrets.env
    if [ -f /var/lib/private/secrets.env ]; then
      PASSWORD=$(grep "CODESERVER_PASSWORD" /var/lib/private/secrets.env | cut -d'=' -f2)
      echo "$PASSWORD" > /home/christopher/.openvscode/.password
      chmod 600 /home/christopher/.openvscode/.password
    fi
    
    # Create simple extension install script for the user
    mkdir -p /home/christopher/.openvscode/scripts
    cat > /home/christopher/.openvscode/scripts/install-nix-extensions.sh << 'EOF'
    #!/bin/bash
    # This script installs modern Nix VS Code extensions
    
    # Install jnoortheen.nix-ide (Modern Nix IDE)
    code-server --install-extension jnoortheen.nix-ide
    
    # Install arrterian.nix-env-selector (Nix environment selector)
    code-server --install-extension arrterian.nix-env-selector
    
    echo "Nix extensions installed! Please restart VS Code Server."
    EOF
    
    chmod +x /home/christopher/.openvscode/scripts/install-nix-extensions.sh
    
    # Set proper permissions
    chown -R 1000:100 /home/christopher/.openvscode
    chown 1000:100 /home/christopher/projects
    echo "OpenVSCode Server directories prepared with Nix integration"
  '';
}
