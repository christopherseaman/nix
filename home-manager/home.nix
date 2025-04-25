{ config, pkgs, ... }:

let
  commonPackages = import ./common-packages.nix { inherit pkgs; };
  guiApps = [];
  # guiApps = import ./gui-apps.nix { inherit pkgs; };
in
{
  home.username = "cseaman";
  home.homeDirectory = "/Users/cseaman";

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
      core = {
        editor = "nvim";
        pager = "delta";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      delta = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
    };
  };
  
  # GitHub CLI
  programs.gh = {
    enable = true;
  };

  home.packages = commonPackages ++ guiApps ++ [
    (pkgs.writeShellScriptBin "aider-chat" ''
      set -a
      . /var/lib/secrets.env
      set +a
      exec ${pkgs.aider-chat}/bin/aider "$@"
    '')
    # Add systemPackages that are user-specific here:
    pkgs.neovim
    pkgs.starship
    pkgs._0xproto
    pkgs.source-code-pro
    pkgs.source-serif
    pkgs.source-sans
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  fonts.fontconfig.enable = true;
}
