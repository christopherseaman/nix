{
  description = "BadMath NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  
    # For user environment management
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Import code-server source directly
    code-server-src = {
      url = "github:coder/code-server";
      flake = false;
    };

    # Useful for flake utilities
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Add inputs to the function parameters
  outputs = { self, nixpkgs, home-manager, code-server-src, flake-utils, ... }@inputs: 
    let 
      # Your system architecture - make sure this is correct
      system = "aarch64-linux";
      
      # Define pkgs for your system
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Build the code-server package using the module
      code-server-pkg = import ./packages/code-server {
        inherit pkgs code-server-src;
      };
    in
    {
      # NixOS configuration
      nixosConfigurations.carnac = nixpkgs.lib.nixosSystem {
        inherit system;
        
        # Pass special arguments to modules
        specialArgs = { 
          inherit code-server-pkg; 
        };
        
        modules = [
          ./configuration.nix
          ./services/caddy.nix
          ./services/duckdns.nix
          ./services/tailscale.nix

          # Disabled in favor of home-manager approach
          # ./services/docker.nix
          # ./services/gitpod.nix
          # ./services/code-server.nix

          # Add Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Pass the code-server-pkg to home-manager modules
            home-manager.extraSpecialArgs = { 
              inherit code-server-pkg; 
            };
            home-manager.users.christopher = import ./home/christopher.nix;
          }
        ];
      };
      
      # Add devShells using flake-utils
      devShells = flake-utils.lib.eachDefaultSystem (system: {
        default = import ./devshells/default.nix { 
          pkgs = nixpkgs.legacyPackages.${system}; 
        };
      });
    };
}
