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
        # Python core
        python311
        python311Packages.pip
        python311Packages.virtualenv
        
        # Development tools
        python311Packages.black
        python311Packages.ruff
        python311Packages.mypy
        python311Packages.uv
        python311Packages.ipython
        
        # Golang 
        go
        gopls
        
        # Development utilities
        git
        nixpkgs-fmt
        nil

        # Shell
        fish
      ];
    }
  '';

  # Create a script that launches a PURE shell with fish
  devShellScript = pkgs.writeShellScriptBin "devshell" ''
    ${pkgs.nix}/bin/nix-shell --pure ${config.home.homeDirectory}/.config/nix/dev-shell.nix --command fish "$@"
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
