{ pkgs }:

with pkgs; [
  # Fonts
  nerdfonts.override { fonts = [ "0xProto" "FiraCode" "FiraMono" "SourceCodePro" "SourceSansPro" "SourceSerifPro" ]; }

  # Desktop apps
  discord
  vscode-fhs
  code-cursor
  _1password
  yt-dlp
  ghostty
  altserver
  signal-desktop
  slack
  spotify
  steam
  vlc
  itsycal
  daisydisk
  handbrake
  mountainduck
  obsidian
  onyx
  transmission_gtk
  balena-etcher
  raspberry-pi-imager
  qflipper
]