# /etc/nixos/home/code-server.nix
{ config, pkgs, ... }:

let
  code-server-pkg = import ../packages/code-server { inherit pkgs; };
  
  # Create a shell script to set up the config
  setupScript = pkgs.writeShellScript "setup-code-server-config" ''
    ${pkgs.coreutils}/bin/mkdir -p ~/.config/code-server
    cat > ~/.config/code-server/config.yaml << EOF
    bind-addr: 127.0.0.1:8080
    auth: password
    password: $PASSWORD
    cert: false
    EOF
    ${pkgs.coreutils}/bin/chmod 600 ~/.config/code-server/config.yaml
  '';
in {
  # Add the code-server package
  home.packages = [ code-server-pkg pkgs.coreutils pkgs.bash pkgs.nodejs ];
  
  # Create a systemd user service
  systemd.user.services.code-server = {
    Unit = {
      Description = "VS Code in the browser";
      After = [ "network.target" ];
    };
    
    Service = {
      Type = "simple";
      # Use a script file instead of inline shell commands to avoid quoting issues
      ExecStartPre = "${setupScript}";
      ExecStart = "${code-server-pkg}/bin/code-server";
      
      # Environment variables - make sure all needed tools are available
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
