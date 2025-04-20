# home/dev-shell.nix
{ config, pkgs, lib, ... }:

with lib;

let
  # Create a pure content with allowUnfree set declaratively
  devShellContent = ''
    let
      # Import nixpkgs with allowUnfree configured directly
      pkgs = import <nixpkgs> { config = { allowUnfree = true; }; };
    in
    pkgs.mkShell {
      packages = with pkgs; [
        # Core tools
        python311
        go
        
        # Development tools
        git
        nixpkgs-fmt
        nil
        fish
        
        # Python packages we want
        python311Packages.pip
        python311Packages.virtualenv
        python311Packages.black
        python311Packages.mypy
        python311Packages.ipython
      ];
      
      # Simple shellHook
      shellHook = '''
        # Disable the command-not-found handler to avoid the database error
        function __command_not_found_handler() {
          echo "Command not found: $1"
          return 127
        }
        
        echo "Development environment activated"
      ''';
    }
  '';

  # Create a script that launches fish in a pure environment but adds minimal
  # required environment variables to make it work well
  devShellScript = pkgs.writeShellScriptBin "devshell" ''
    ${pkgs.nix}/bin/nix-shell --pure \
      --keep HOME \
      --keep TERM \
      --keep TERMINFO \
      --keep COLORTERM \
      ${config.home.homeDirectory}/.config/nix/dev-shell.nix --command fish "$@"
  '';
  
  # Also create an impure version that preserves environment variables
  impureDevShellScript = pkgs.writeShellScriptBin "impure-devshell" ''
    ${pkgs.nix}/bin/nix-shell ${config.home.homeDirectory}/.config/nix/dev-shell.nix --command fish "$@"
  '';
in
{
  # This places the scripts in ~/.nix-profile/bin
  home.packages = [ devShellScript impureDevShellScript ];
  
  # This creates the shell.nix file
  home.file.".config/nix/dev-shell.nix".text = devShellContent;
}
