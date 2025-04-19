{ config, pkgs, ... }: {
  # Enable Caddy web server
  services.caddy = {
    enable = true;
    
    # Configure Caddy with HTTP-only operation
    configFile = pkgs.writeText "Caddyfile" ''
      {
        auto_https disable_redirects
      }
      
      :80, carnac.badmath.org, codernac.duckdns.org {
        reverse_proxy localhost:8443 {
          header_up Host {host}
	  header_up X-Real-IP {remote}
	  header_up X-Forwarded-For {remote}
	  header_up X-Forwarded-Proto {scheme}
	}
      }
    '';
  };
  
  # Create Caddy log directory
  systemd.tmpfiles.rules = [
    "d /var/log/caddy 0755 caddy caddy -"
  ];
  
  # Open required ports
  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];  # Keep both ports open
  };
}
