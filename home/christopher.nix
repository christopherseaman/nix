# /etc/nixos/home/christopher.nix
{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;

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

  home.packages = with pkgs; [
    git-lfs
    gitAndTools.delta
    tmux
  ];
}
