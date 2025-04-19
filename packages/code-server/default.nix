# /etc/nixos/packages/code-server/default.nix
{ pkgs }:

let
  version = "4.99.3";
  platform = "linux-arm64";
  hash = "sha256-nO9nzfvN9Y11LFGm8bqkmzhAuTGN2k8TxfLShGLsvdE=";
in
pkgs.stdenv.mkDerivation {
  pname = "code-server";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://github.com/coder/code-server/releases/download/v${version}/code-server-${version}-${platform}.tar.gz";
    sha256 = hash;
  };

  # Extract the archive first
  sourceRoot = ".";
  
  # Add runtime dependencies required by the binary
  nativeBuildInputs = with pkgs; [ 
    autoPatchelfHook
    makeWrapper 
  ];
  
  # Libraries needed for code-server to run
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    libsecret
    krb5
    xorg.libxkbfile
    xorg.libX11
    nodejs
  ];

  # Fix paths and patch ELF binaries
  installPhase = ''
    mkdir -p $out
    cp -r ./code-server-${version}-${platform}/* $out/
    
    # Fix the path to Node.js in the code-server script
    substituteInPlace $out/bin/code-server \
      --replace '#!/usr/bin/env -S node' '#!${pkgs.nodejs}/bin/node'
    
    # Make sure the binaries are executable
    chmod +x $out/bin/code-server
    
    # Wrap the binary to ensure it has access to required runtime libraries
    wrapProgram $out/bin/code-server \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nodejs ]} \
      --set NODE_PATH $out/lib/node_modules
  '';

  meta = with pkgs.lib; {
    description = "VS Code in the browser";
    homepage = "https://github.com/coder/code-server";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
