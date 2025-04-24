{ config, pkgs, ... }:

let
  commonPackages = import ./common-packages.nix { inherit pkgs; };
in
{
  home.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./pbcopy.nix
    ./code-server.nix
    ./dev-shell.nix
    ./nix-rebuild.nix
  ];

  # Fish Shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Fish shell customizations
      set -g fish_greeting ""  # Disable greeting
    
      # Initialize starship prompt if installed
      command -v starship >/dev/null && starship init fish | source
    '';
  
    # Add your fish plugins if desired
    plugins = [
      # Examples:
      # { name = "z"; src = pkgs.fishPlugins.z.src; }
      # { name = "fzf"; src = pkgs.fishPlugins.fzf.src; }
    ];
  
    #shellAliases = {
    #  # Your preferred aliases
    #  ll = "ls -la";
    #  ".." = "cd ..";
    #  "..." = "cd ../..";
    #};
  };

  # SSH
  programs.ssh = {
    enable = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Christopher Seaman";
    userEmail = "86775+christopherseaman@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      safe.directory = [ "/etc/nixos" ];
    };
  };
  
  # GitHub CLI
  programs.gh = {
    enable = true;
  };

  home.packages = commonPackages ++ [
    (pkgs.writeShellScriptBin "aider-chat" ''
      set -a
      . /var/lib/secrets.env
      set +a
      exec ${pkgs.aider-chat}/bin/aider "$@"
    '')
  ];
}
