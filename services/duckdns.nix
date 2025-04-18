{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.duckdns;
in {
  options.services.duckdns = {
    enable = mkEnableOption "DuckDNS dynamic DNS service";
    
    domain = mkOption {
      type = types.str;
      description = "Your DuckDNS subdomain (without the duckdns.org part)";
      example = "codernac";
      default = "codernac";  # Pre-configured with your domain
    };
    
    tokenEnvironmentFile = mkOption {
      type = types.str;
      description = "Path to environment file containing DUCKDNS_TOKEN";
      default = "/var/lib/private/secrets.env";
    };
    
    interval = mkOption {
      type = types.int;
      default = 5;
      description = "Update interval in minutes";
    };
    
    ipv4 = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to update IPv4 records";
    };
    
    ipv6 = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to update IPv6 records";
    };
  };

  config = mkMerge [
    # Module implementation
    (mkIf cfg.enable {
      systemd.services.duckdns = {
        description = "DuckDNS Dynamic DNS Updater";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        
        # Create a timer that runs the service periodically
        startAt = "*:0/${toString cfg.interval}";
        
        serviceConfig = {
          Type = "oneshot";
          DynamicUser = true;
          PrivateTmp = true;
          EnvironmentFile = cfg.tokenEnvironmentFile;
          ExecStart = toString (pkgs.writeShellScript "duckdns-update" ''
            ${pkgs.curl}/bin/curl ${optionalString cfg.ipv4 "--ipv4"} ${optionalString cfg.ipv6 "--ipv6"} \
              "https://www.duckdns.org/update?domains=${cfg.domain}&token=$DUCKDNS_TOKEN&ip=" \
              -o /tmp/duck.log
          '');
        };
      };
    })

    # Your specific configuration
    {
      # Enable the service by default
      services.duckdns.enable = mkDefault true;
      
      # Your pre-configured settings
      services.duckdns = {
        domain = "codernac";
        tokenEnvironmentFile = "/var/lib/private/secrets.env";
        interval = 5;  # Update every 5 minutes
        ipv4 = true;
        ipv6 = false;
      };
    }
  ];
}
