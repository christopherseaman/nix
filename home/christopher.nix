# /etc/nixos/home/christopher.nix
{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";

  imports = [
    ./pbcopy.nix
    ./code-server.nix
    ./dev-shell.nix
    ./nix-rebuild.nix
  ];

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

  # VSCode configuration
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      golang.go
      jnoortheen.nix-ide
    ];

    userSettings = {
      "python.defaultInterpreterPath" = "${config.home.homeDirectory}/.venv/bin/python";
      "python.linting.enabled" = true;
      "python.linting.ruffEnabled" = true;
      "editor.formatOnSave" = true;
    };
  };

  # Keep the path config for any future scripts you might add
  # home.sessionPath = [ "$HOME/.local/bin" ];
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  # You can also remove code-server from home.packages if you're only using the Docker service
  home.packages = with pkgs; [
    git-lfs  # Optional: Git Large File Storage
    gitAndTools.delta  # Optional: Better diff tool
    tmux
  ];
}
