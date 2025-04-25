{ pkgs }:

with pkgs; [
  # Fonts
  nerdfonts.override { fonts = [ "SourceCodePro" "SourceSansPro" "SourceSerifPro" ]; }
  nerd-fonts._0xproto
  nerd-fonts.FiraCode
  nerd-fonts.FiraMono
  nerd-fonts.SourceCodePro
  source-serif
  source-sans
  ia-writer-quattro

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