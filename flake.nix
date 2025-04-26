# flake.nix
{
  description = "BadMath NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  
    # For user environment management
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Useful for flake utilities
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Add inputs to the function parameters
  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs: 
    let 
      # Your system architecture - make sure this is correct
      system = "aarch64-linux";
      
      # Define overlays to customize packages
      overlays = [ ];

      # Configure nixpkgs with overlays and allow unfree packages globally
      pkgsForSystem = system: import nixpkgs {
        inherit system overlays;
        config = { 
          allowUnfree = true;
          # Optional: If needed, you can add more config here
        };
      };
      
      # Define pkgs for your system using the configured nixpkgs
      pkgs = pkgsForSystem system;
    in
    {
      # NixOS configuration
      nixosConfigurations.carnac = nixpkgs.lib.nixosSystem {
        inherit system;
        
        modules = [
          # Set allowUnfree globally in the NixOS configuration
          { nixpkgs.config.allowUnfree = true; }
          
          ./configuration.nix
          ./services/caddy.nix
          ./services/duckdns.nix
          ./services/tailscale.nix
          ./services/docker.nix

          # Add Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.christopher = import ./home-manager/home.nix;
          }
        ];
      };
    };
}
