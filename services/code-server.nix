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

  # Ensure the basic directories exist and create setup scripts
  system.activationScripts.mkCodeServerDirs = ''
    mkdir -p /home/christopher/.code-server
    mkdir -p /home/christopher/projects
    
    # Create setup script
    mkdir -p /home/christopher/.code-server/custom-cont-init.d
    cat > /home/christopher/.code-server/custom-cont-init.d/99-install-dev-tools.sh << 'EOF'
    #!/bin/bash
    
    # Skip if already installed
    if [ -f /config/.dev-tools-installed ]; then
      echo "Dev tools already installed"
      exit 0
    fi
    
    echo "Installing development tools..."
    
    # Update package lists
    apt-get update
    
    # Install basic development tools
    apt-get install -y \
      git \
      curl \
      wget \
      build-essential \
      python3 \
      python3-pip \
      python3-venv \
      nodejs \
      npm \
      golang
    
    # Install Python development tools
    pip3 install black mypy ruff ipython
    
    # Install VS Code extensions
    code-server --install-extension ms-python.python
    code-server --install-extension golang.go
    code-server --install-extension ms-vscode.cpptools
    
    # Create marker file
    touch /config/.dev-tools-installed
    
    echo "Development tools installed!"
    EOF
    chmod +x /home/christopher/.code-server/custom-cont-init.d/99-install-dev-tools.sh
    
    # Set proper permissions
    chown -R 1000:100 /home/christopher/.code-server
    chown 1000:100 /home/christopher/projects
  '';
}
