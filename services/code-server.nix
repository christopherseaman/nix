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
        # Set NIX_REMOTE to use the host daemon
        NIX_REMOTE = "daemon";
        # Make Nix commands work inside the container
        NIX_CONF_DIR = "/etc/nix";
        # Home directory inside container
        HOME = "/config";
        # Add HOME/.nix-profile/bin to PATH
        PATH = "/config/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
      };
      volumes = [
        "/home/christopher/.code-server:/config"
        "/home/christopher/projects:/config/workspace"
        "/nix:/nix:ro"
        "/etc/nix:/etc/nix:ro"
        "/run/current-system:/run/current-system:ro"
        "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        "/nix/var/nix/profiles:/nix/var/nix/profiles:ro"
        # Add host user's profile
        "/home/christopher/.nix-profile:/config/.nix-profile:ro"
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
    
    # Add any special host environment variables here
    export NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels
    
    # Let the system know we've initialized Nix
    export NIX_INITIALIZED=1
    EOF
    chmod +x /home/christopher/.code-server/scripts/nix-init.sh
    
    # Create helper script for installing Nix extensions
    cat > /home/christopher/.code-server/scripts/install-nix-extensions.sh << 'EOF'
    #!/bin/bash
    code-server --install-extension jnoortheen.nix-ide
    code-server --install-extension arrterian.nix-env-selector
    code-server --install-extension janw4ld.lambda-black
    echo "Nix extensions and Lambda Black theme installed! Please restart VS Code Server."
    EOF
    chmod +x /home/christopher/.code-server/scripts/install-nix-extensions.sh
    
    # Create a custom shell RC file to initialize Nix in terminals
    cat > /home/christopher/.code-server/.bashrc << 'EOF'
    # Source global definitions
    if [ -f /etc/bashrc ]; then
        . /etc/bashrc
    fi
    
    # Initialize Nix environment
    if [ -f /config/scripts/nix-init.sh ]; then
        source /config/scripts/nix-init.sh
    fi
    
    # User specific aliases and functions
    alias nrs='sudo nixos-rebuild switch'
    alias nrb='sudo nixos-rebuild boot'
    alias nrt='sudo nixos-rebuild test'
    
    # Enable showing git branch in prompt
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " (%s)") \$ '
    EOF
    
    # Create a settings.json with terminal profile and Lambda Black theme
    mkdir -p /home/christopher/.code-server/data/Machine
    cat > /home/christopher/.code-server/data/Machine/settings.json << 'EOF'
    {
      "workbench.colorTheme": "Lambda Black",
      "editor.formatOnSave": true,
      "nix.enableLanguageServer": true,
      "nix.serverPath": "nil",
      "nix.serverSettings": {
        "nil": {
          "formatting": {
            "command": ["nixpkgs-fmt"]
          }
        }
      },
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
    
    # Set proper permissions
    chown -R 1000:100 /home/christopher/.code-server
    chown 1000:100 /home/christopher/projects
  '';
}
