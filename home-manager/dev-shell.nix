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
        python312
        go
        
        # Development tools
        git
        nixpkgs-fmt
        nil
        fish
        uv
	ruff

        # Add starship for your prompt
        starship
        
        # Python packages we want
        python312Packages.pip
        python312Packages.virtualenv
        python312Packages.black
        python312Packages.mypy
        python312Packages.ipython
      ];
      
      # Better shellHook that preserves Fish configuration
      shellHook = '''
        # Create a fish-specific environment setup that preserves PATH
        # but doesn't override your existing config
        mkdir -p ~/.config/fish/conf.d
        echo "set -x NIX_SHELL_PATH $PATH" > ~/.config/fish/conf.d/nix-shell-path.fish
        echo "set -gx PATH \$NIX_SHELL_PATH \$PATH" >> ~/.config/fish/conf.d/nix-shell-path.fish
        
        # Make sure starship is available
        echo "if command -v starship &>/dev/null" >> ~/.config/fish/conf.d/nix-shell-path.fish
        echo "  starship init fish | source" >> ~/.config/fish/conf.d/nix-shell-path.fish 
        echo "end" >> ~/.config/fish/conf.d/nix-shell-path.fish
        
        echo "Development environment activated"
      ''';
    }
  '';

  # Create a script that launches the shell with appropriate environment variables
  devShellScript = pkgs.writeShellScriptBin "devshell-bash" ''
    ${pkgs.nix}/bin/nix-shell --pure \
      --keep HOME \
      --keep TERM \
      --keep TERMINFO \
      --keep COLORTERM \
      --keep STARSHIP_CONFIG \
      --keep XDG_CONFIG_HOME \
      --keep XDG_DATA_HOME \
      --keep XDG_CACHE_HOME \
      ${config.home.homeDirectory}/.config/nix/dev-shell.nix
  '';
  
  # Direct fish devshell
  fishDevShellScript = pkgs.writeShellScriptBin "devshell" ''
    ${pkgs.nix}/bin/nix-shell --pure \
      --keep HOME \
      --keep TERM \
      --keep TERMINFO \
      --keep COLORTERM \
      --keep STARSHIP_CONFIG \
      --keep XDG_CONFIG_HOME \
      --keep XDG_DATA_HOME \
      --keep XDG_CACHE_HOME \
      ${config.home.homeDirectory}/.config/nix/dev-shell.nix --command "fish -C 'source ~/.config/fish/conf.d/nix-shell-path.fish'"
  '';
in
{
  # This places the scripts in ~/.nix-profile/bin
  home.packages = [ devShellScript fishDevShellScript ];
  
  # This creates the shell.nix file
  home.file.".config/nix/dev-shell.nix".text = devShellContent;
}
