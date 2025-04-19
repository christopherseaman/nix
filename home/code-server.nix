# /etc/nixos/home/code-server.nix
{ config, pkgs, ... }:

let
  code-server-pkg = import ../packages/code-server { inherit pkgs; };
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
      # Use code-server directly, since it now has a proper wrapper script
      # Use an array for ExecStartPre instead of multiple assignments
      ExecStartPre = [
        "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/mkdir -p ~/.config/code-server && ${pkgs.coreutils}/bin/cat > ~/.config/code-server/config.yaml << EOF\nbind-addr: 127.0.0.1:8080\nauth: password\npassword: $PASSWORD\ncert: false\nEOF\n'"
        "${pkgs.coreutils}/bin/chmod 600 ~/.config/code-server/config.yaml"
      ];
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
