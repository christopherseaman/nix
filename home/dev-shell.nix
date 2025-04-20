# home/dev-shell.nix
{ config, pkgs, lib, ... }:

with lib;

let
  devShellScript = pkgs.writeShellScriptBin "devshell" ''
    ${pkgs.nix}/bin/nix-shell ${config.home.homeDirectory}/.config/nix/dev-shell.nix --command fish "$@"
  '';
  
  devShellContent = ''
    { pkgs ? import <nixpkgs> {} }:

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
        
        # IDE support
        # vscodium # Maybe if we add a GUI later
      ];
      
      #shellHook = '''
      #  # Python virtual environment setup
      #  if [ ! -d .venv ]; then
      #    uv venv
      #  fi
      #  source .venv/bin/activate
      #   
      #  # Go setup
      #  export GOPATH=$HOME/go
      #  
      #  echo "Development environment ready!"
      #''';
    }
  '';
in
{
  # This places the script in ~/.nix-profile/bin
  home.packages = [ devShellScript ];
  
  # This creates the shell.nix file
  home.file.".config/nix/dev-shell.nix".text = devShellContent;
}
