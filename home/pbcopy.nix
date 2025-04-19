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
	if [ -n "$1" ]; then
	  if [ ! -r "$1" ]; then
	    echo "Error: File not found or not readable: $1" >&2
	    exit 1
	  fi
	  input_content=$(cat "$1")
	  input_desc="file '$1'"
        else
	  input_content=$(cat -)
	  input_desc="stdin"
	fi

	# Base64 encode the content
	encoded=$(echo -n "$input_content" | base64 -w 0)

	# Detect if we're in tmux and use the appropriate sequence
	if [ -n "$TMUX" ]; then
	  # Inside tmux - wrap OSC 52 sequence with DCS tmux escape sequences
	  printf "\ePtmux;\e\e]52;c;%s\a\e\\" "$encoded"
	else
	  # Outside tmux - use normal OSC 52 sequence
	  printf "\e]52;c;%s\a" "$encoded"
	fi
      '';
      executable = true;
    };

    #home.file.".local/bin/pbpaste" = {
    #  text = ''
    #    #!/bin/sh
    #    exec ${pkgs.xsel}/bin/xsel --clipboard --output "$@"
    #  '';
    #  executable = true;
    #};
  };
}
