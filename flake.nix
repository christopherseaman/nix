{
  description = "A simple NixOS flake";

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

  # Add home-manager to the function parameters
  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs: 
    let 
      # Define supported systems
      supportedSystems = [ "aarch64-linux" "x86_64-linux" ];
    in
    {
      # NixOS configuration
      nixosConfigurations.carnac = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        
        modules = [
          ./configuration.nix
          ./services/caddy.nix
          # ./services/docker.nix
	  ./services/duckdns.nix
          # ./services/gitpod.nix
	  # ./services/code-server.nix
          ./services/pbcopy.nix
	  ./services/tailscale.nix

          { services.pbcopy.enable = true; }

          # Add Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.christopher = import ./home/christopher.nix;
          }
        ];
      };
    } // flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Development shell
        devShells.default = import ./devshells/default.nix { inherit pkgs; };
      }
    );
}
