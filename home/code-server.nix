# /etc/nixos/home/code-server.nix
{ config, pkgs, ... }:

let
  code-server-pkg = import ../packages/code-server { inherit pkgs; };
in {
  # Add the code-server package
  home.packages = [ code-server-pkg ];
  
  # Create a systemd user service
  systemd.user.services.code-server = {
    Unit = {
      Description = "VS Code in the browser";
      After = [ "network.target" ];
    };
    
    Service = {
      Type = "simple";
      # Use a simple script to setup and run code-server
      ExecStart = pkgs.writeShellScript "start-code-server" ''
        #!${pkgs.bash}/bin/bash
        
        # Set PATH to include basic utilities
        export PATH="${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin:$PATH"
        
        # Create the config directory
        mkdir -p ~/.config/code-server
        
        # Create the config file
        cat > ~/.config/code-server/config.yaml << EOF
        bind-addr: 127.0.0.1:8080
        auth: password
        password: $PASSWORD
        cert: false
        EOF
        
        # Set permissions
        chmod 600 ~/.config/code-server/config.yaml
        
        # Run code-server
        exec ${code-server-pkg}/bin/code-server
      '';
      
      # Environment variables
      Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin:/run/current-system/sw/bin";
      EnvironmentFile = "/var/lib/private/secrets.env";
      
      # Restart settings
      Restart = "always";
      RestartSec = "10";
    };
    
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
