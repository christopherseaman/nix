# /etc/nixos/home/pbcopy.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pbcopy;
in {
  options.pbcopy = {
    enable = mkEnableOption "Enable pbcopy and pbpaste commands";
  };

  config = mkIf cfg.enable {
    # Use home.packages instead of environment.systemPackages
    home.packages = with pkgs; [
      xsel
    ];

    # Create scripts in ~/.local/bin
    home.file.".local/bin/pbcopy" = {
      text = ''
        #!/bin/sh
        exec ${pkgs.xsel}/bin/xsel --clipboard --input "$@"
      '';
      executable = true;
    };

    home.file.".local/bin/pbpaste" = {
      text = ''
        #!/bin/sh
        exec ${pkgs.xsel}/bin/xsel --clipboard --output "$@"
      '';
      executable = true;
    };
  };
}
