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
        NIX_REMOTE = "daemon";
        NIX_CONF_DIR = "/etc/nix";
        HOME = "/config";
        PATH = "/nix/var/nix/profiles/default/bin:/config/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
        # Enable experimental features
        NIX_CONFIG = "experimental-features = nix-command flakes";
      };
      volumes = [
        "/home/christopher/.code-server:/config"
        "/home/christopher/projects:/config/workspace"
        "/nix:/nix:ro"
        "/etc/nix:/etc/nix:ro"
        "/run/current-system:/run/current-system:ro"
        "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        "/nix/var/nix/profiles:/nix/var/nix/profiles:ro"
        "/home/christopher/.nix-profile:/config/.nix-profile:ro"
        "/run/current-system/sw:/run/current-system/sw:ro"
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

  system.activationScripts.mkCodeServerDirs = ''
    mkdir -p /home/christopher/.code-server
    mkdir -p /home/christopher/projects
    
    # Create nix-shell initialization script
    mkdir -p /home/christopher/.code-server/scripts
    cat > /home/christopher/.code-server/scripts/nix-init.sh << 'EOF'
    #!/bin/bash
    
    # Source nix environment if available
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
      source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    
    # Source user profile if available
    if [ -f /config/.nix-profile/etc/profile.d/nix.sh ]; then
      source /config/.nix-profile/etc/profile.d/nix.sh
    fi
    
    # Add current-system bins to PATH
    export PATH="/run/current-system/sw/bin:$PATH"
    
    # Enable experimental features for nix-command and flakes
    export NIX_CONFIG="experimental-features = nix-command flakes"
    
    # Add any special host environment variables here
    export NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels
    
    # Let the system know we've initialized Nix
    export NIX_INITIALIZED=1
    EOF
    chmod +x /home/christopher/.code-server/scripts/nix-init.sh
    
    # Create helper script for installing extensions
    cat > /home/christopher/.code-server/scripts/install-extensions.sh << 'EOF'
    #!/bin/bash
    code-server --install-extension jnoortheen.nix-ide
    code-server --install-extension arrterian.nix-env-selector
    code-server --install-extension janw4ld.lambda-black
    echo "Extensions installed! Please restart VS Code Server."
    EOF
    chmod +x /home/christopher/.code-server/scripts/install-extensions.sh
    
    # Create a custom shell RC file
    cat > /home/christopher/.code-server/.bashrc << 'EOF'
    # Initialize Nix environment
    if [ -f /config/scripts/nix-init.sh ]; then
        source /config/scripts/nix-init.sh
    fi
    
    # Simple prompt
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \$ '
    
    # Aliases
    alias nrs='sudo nixos-rebuild switch'
    alias nrb='sudo nixos-rebuild boot'
    alias nrt='sudo nixos-rebuild test'
    
    # Print status
    echo "Nix environment initialized"
    nix --version 2>/dev/null && echo "✓ Nix is available" || echo "❌ Nix is not available"
    EOF
    
    # Create settings.json
    mkdir -p /home/christopher/.code-server/data/Machine
    cat > /home/christopher/.code-server/data/Machine/settings.json << 'EOF'
    {
      "workbench.colorTheme": "Lambda Black",
      "editor.formatOnSave": true,
      "nix.enableLanguageServer": true,
      "nix.serverPath": "nil",
      "terminal.integrated.profiles.linux": {
        "nix-bash": {
          "path": "/bin/bash",
          "args": ["--rcfile", "/config/.bashrc"],
          "icon": "terminal-bash"
        }
      },
      "terminal.integrated.defaultProfile.linux": "nix-bash"
    }
    EOF
    
    # Make sure both /etc/nix/nix.conf on host has experimental features enabled
    if [ -f /etc/nix/nix.conf ] && ! grep -q "experimental-features" /etc/nix/nix.conf; then
      echo "Adding experimental-features to /etc/nix/nix.conf"
      echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
    fi
    
    # Set proper permissions
    chown -R 1000:100 /home/christopher/.code-server
    chown 1000:100 /home/christopher/projects
  '';
}
