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
    coreutils
  ];

  # Fix paths and patch ELF binaries
  installPhase = ''
    mkdir -p $out
    cp -r ./code-server-${version}-${platform}/* $out/
    
    # Create a wrapper script
    mv $out/bin/code-server $out/bin/code-server-original
    cat > $out/bin/code-server << EOF
    #!${pkgs.bash}/bin/bash
    export PATH="${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin:\$PATH"
    exec ${pkgs.nodejs}/bin/node $out/lib/node_modules/code-server/out/node/entry.js "\$@"
    EOF
    
    chmod +x $out/bin/code-server
    
    # Make sure all scripts have proper paths
    for f in $out/bin/* $out/lib/node_modules/code-server/bin/*; do
      if [ -f "$f" ] && [ -x "$f" ]; then
        wrapProgram "$f" \
          --prefix PATH : ${pkgs.lib.makeBinPath [ 
            pkgs.nodejs 
            pkgs.coreutils 
            pkgs.bash
          ]}
      fi
    done || true
  '';

  meta = with pkgs.lib; {
    description = "VS Code in the browser";
    homepage = "https://github.com/coder/code-server";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
