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
      
      # Create a fish-specific shellHook that preserves the PATH
      shellHook = '''
        # Create a fish-specific environment setup
        mkdir -p ~/.config/fish/conf.d
        echo "set -x PATH $PATH" > ~/.config/fish/conf.d/nix-shell-path.fish
        
        echo "Development environment activated"
      ''';
    }
  '';

  # Create a script that directly launches fish with the proper environment
  devShellScript = pkgs.writeShellScriptBin "devshell" ''
    ${pkgs.nix}/bin/nix-shell --pure \
      --keep HOME \
      --keep TERM \
      --keep TERMINFO \
      --keep COLORTERM \
      ${config.home.homeDirectory}/.config/nix/dev-shell.nix
  '';
in
{
  # This places the scripts in ~/.nix-profile/bin
  home.packages = [ devShellScript ];
  
  # This creates the shell.nix file
  home.file.".config/nix/dev-shell.nix".text = devShellContent;
}
