{ config, lib, pkgs, ... }:

let
  openvscode-version = "1.98.2";
  openvscode-hash = "sha256-9NHUbvzNgfb7EfsRyT8/KoNylSWD+15soGsAcu8baKk=";

  # Create package for openvscode-server but call it code-server
  code-server = pkgs.stdenv.mkDerivation {
    pname = "code-server";
    version = openvscode-version;
    
    src = pkgs.fetchurl {
      url = "https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v${openvscode-version}/openvscode-server-v${openvscode-version}-linux-arm64.tar.gz";
      hash = openvscode-hash; # Will be prompted during build
    };
    
    # Add patchelf to fix dynamic linking issues
    nativeBuildInputs = [ pkgs.makeWrapper pkgs.autoPatchelfHook ];
    
    # Required libraries for dynamic linking
    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      libsecret
      libkrb5
      xorg.libxshmfence
      util-linux
      xorg.libxkbfile
      xorg.libX11
      xorg.libXdamage
      xorg.libXrandr
      xorg.libXcomposite
      xorg.libXext
      xorg.libXfixes
      alsa-lib
      cups
      mesa
      expat
      nodejs
      ripgrep
    ];
    
    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
      
      # Ensure path to node and other tools is correct
      wrapProgram $out/bin/openvscode-server \
        --prefix PATH : ${lib.makeBinPath [ pkgs.nodejs pkgs.ripgrep ]}
    '';
  };
in {
  # Home Manager user service - using the name code-server
  systemd.user.services.code-server = {
    Unit = {
      Description = "VS Code Server";
      After = [ "network.target" ];
    };
    
    Service = {
      # Start the server with common options
      ExecStart = "${code-server}/bin/openvscode-server --port 8443 --host 127.0.0.1 --connection-token-file ~/.config/code-server/secrets.env";
      
      Restart = "on-failure";
      RestartSec = 5;
      
      # Environment settings
      Environment = "OPENVSCODE_SERVER_DATA_FOLDER=${config.home.homeDirectory}/.local/share/code-server";
    };
    
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
  
  # Add openvscode-server to user packages (as code-server)
  home.packages = [
    code-server
  ];

  # Create necessary directory for data storage
  home.file.".local/share/code-server/.keep".text = "";
}
