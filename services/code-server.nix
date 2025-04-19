{ config, pkgs, ... }: {
  virtualisation.oci-containers.containers = {
    code-server = {
      image = "linuxserver/code-server:latest";
      ports = ["127.0.0.1:3000:8443"];  # Map to 3000 on host, 8443 in container
      environment = {
        # Hardcoded UIDs to match your system
        PUID = "1000";
        PGID = "100";
        TZ = config.time.timeZone;
        
        # Optional: provide sudo password for container user
        SUDO_PASSWORD = "def";
        # Use password from secrets.env
        PASSWORD = "$CODESERVER_PASSWORD";

        # SSH agent forwarding
        SSH_AUTH_SOCK = "/config/ssh-agent.sock";
        
        # Default workspace
        DEFAULT_WORKSPACE = "/config/workspace";
      };
      volumes = [
        # Config and project data
        "/home/christopher/.code-server:/config"
        "/home/christopher/projects:/config/workspace"
        
        # Nix integration
        "/nix:/nix:ro"
        "/etc/nix:/etc/nix:ro"
        "/run/current-system:/run/current-system:ro"
        "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        "/nix/var/nix/profiles:/nix/var/nix/profiles:ro"
        
        # Don't mount /etc/passwd and /etc/group since they're causing issues
        # "/etc/passwd:/etc/passwd:ro"
        # "/etc/group:/etc/group:ro"
        
        "/etc/resolv.conf:/etc/resolv.conf:ro"
        "/etc/ssl:/etc/ssl:ro"
        
        # SSH agent forwarding
        "/run/user/1000/keyring/ssh:/config/ssh-agent.sock:ro"

        # Mount nixos config but in a way that won't have permission issues
        "/etc/nixos:/config/nixos-config:ro"
      ];
      environmentFiles = [
        "/var/lib/private/secrets.env"
      ];
      extraOptions = [
        "--security-opt=seccomp=unconfined"
      ];
      # Add hostname here to avoid host resolution issues
      hostname = "code-server";
      autoStart = true;
    };
  };

  # Setup directories and create etc-passwd file
  system.activationScripts.mkCodeServerDirs = ''
    mkdir -p /home/christopher/.code-server
    mkdir -p /home/christopher/projects
    
    # Create custom passwd and group files for the container
    echo "abc:x:1000:100:abc:/config:/bin/bash" > /home/christopher/.code-server/passwd
    echo "users:x:100:abc" > /home/christopher/.code-server/group
    echo "abc:x:100:" >> /home/christopher/.code-server/group
    chmod 644 /home/christopher/.code-server/passwd /home/christopher/.code-server/group
    
    # Create script to copy SSH keys (safer than mounting directly)
    mkdir -p /home/christopher/.code-server/keys
    cp -Lr /home/christopher/.ssh/* /home/christopher/.code-server/keys/ 2>/dev/null || true
    cp -L /home/christopher/.gitconfig /home/christopher/.code-server/gitconfig 2>/dev/null || true
    
    # Create helper script for installing Nix extensions
    mkdir -p /home/christopher/.code-server/scripts
    cat > /home/christopher/.code-server/scripts/install-nix-extensions.sh << 'EOF'
    #!/bin/bash
    # Install modern Nix extensions
    code-server --install-extension jnoortheen.nix-ide
    code-server --install-extension arrterian.nix-env-selector
    echo "Nix extensions installed! Please restart VS Code Server."
    EOF
    chmod +x /home/christopher/.code-server/scripts/install-nix-extensions.sh
    
    # Set proper permissions
    chown -R 1000:100 /home/christopher/.code-server
    chown 1000:100 /home/christopher/projects
    echo "Code Server directories prepared with Nix integration"
  '';
}
