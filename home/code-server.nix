{ config, lib, pkgs, ... }:

let
  code-server-version = "4.99.3";
  code-server-hash = "sha256-nO9nzfvN9Y11LFGm8bqkmzhAuTGN2k8TxfLShGLsvdE=";

  # Create a package for the specific code-server version you want
  code-server-custom = pkgs.stdenv.mkDerivation {
    pname = "code-server";
    version = code-server-version;
    
    src = pkgs.fetchurl {
      url = "https://github.com/coder/code-server/releases/download/v${code-server-version}/code-server-${code-server-version}-linux-arm64.tar.gz";
      hash = code-server-hash;
    };
    
    # Add autoPatchelfHook to fix dynamic linking issues
    nativeBuildInputs = [ pkgs.makeWrapper pkgs.autoPatchelfHook ];
    
    # Add required libraries for dynamic linking
    buildInputs = with pkgs; [
      stdenv.cc.cc.lib  # This provides libstdc++
      zlib
      openssl
      libsecret
      util-linux
      xorg.libxkbfile
      xorg.libX11
      nodejs
      ripgrep
    ];
    
    installPhase = ''
      mkdir -p $out
      tar -xzf $src -C $out --strip-components=1
      
      # Fix the path to node
      makeWrapper $out/bin/code-server $out/bin/code-server-wrapped \
        --prefix PATH : ${lib.makeBinPath [ pkgs.nodejs pkgs.ripgrep ]} \
        --set NODE_PATH $out/lib/node_modules
      
      mv $out/bin/code-server-wrapped $out/bin/code-server
    '';
  };
in {
  # Home Manager user service
  systemd.user.services.code-server = {
    Unit = {
      Description = "VS Code Server";
      After = [ "network.target" ];
    };
    
    Service = {
      ExecStart = "${code-server-custom}/bin/code-server --host 127.0.0.1 --port 8443 --auth password";
      Restart = "on-failure";
      RestartSec = 5;
      # Load password directly from secrets.env
      EnvironmentFile = "/var/lib/private/secrets.env";
    };
    
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
  
  # Add code-server to user packages
  home.packages = [
    code-server-custom
    
    # Helper script for Nix extensions
    (pkgs.writeShellScriptBin "install-code-server-nix-extensions" ''
      ${code-server-custom}/bin/code-server --install-extension jnoortheen.nix-ide
      ${code-server-custom}/bin/code-server --install-extension arrterian.nix-env-selector
      echo "Nix extensions installed! Please restart VS Code Server."
    '')
  ];

  # Create necessary directories
  home.file.".config/code-server/.keep".text = "";
  home.file.".local/share/code-server/extensions/.keep".text = "";
}
