# /etc/nixos/home/pbcopy.nix
{ pkgs, ... }:

let
  pbcopy = pkgs.writeShellScriptBin "pbcopy" ''
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
in
{
  # Simply add the packages directly
  home.packages = [
    pbcopy
  ];
}
