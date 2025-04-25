{ pkgs }:

[
  # Fonts
  pkgs.nerdfonts.override { fonts = [ "0xProto" "FiraCode" "FiraMono" "SourceCodePro" "SourceSansPro" "SourceSerifPro" ]; }

  # Desktop apps
  pkgs.discord
  pkgs.vscode
  pkgs.cursor # If available in your channel, otherwise use a custom package or overlay
  pkgs._1password
  pkgs.yt-dlp
  pkgs.ghostty
  pkgs.altserver
  pkgs.signal-desktop
  pkgs.slack
  pkgs.spotify
  pkgs.steam
  pkgs.vlc
  pkgs.itsycal
  pkgs.daisydisk
  pkgs.handbrake
  pkgs.mountainduck
  pkgs.obsidian
  pkgs.onyx
  pkgs.transmission_gtk
  pkgs.balena-etcher
  pkgs.raspberry-pi-imager
  pkgs.qflipper
]