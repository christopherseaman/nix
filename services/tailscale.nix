{ config, pkgs, ... }: {
  # Enable Tailscale service
  services.tailscale = {
    enable = true;
    
    # Optional settings
    useRoutingFeatures = "client"; # Use Tailscale for routing
    # Other options: "server" (exit node) or "both"
  };
  
  # Open firewall for Tailscale
  networking.firewall = {
    # Enable the firewall
    # enable = true;
    
    # Allow Tailscale traffic
    trustedInterfaces = [ "tailscale0" ];
    
    # Allow incoming connections from your Tailscale network
    allowedUDPPorts = [ config.services.tailscale.port ]; # Default is 41641
  };
  
  # Optional: Enable IP forwarding for Tailscale subnet routing
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
