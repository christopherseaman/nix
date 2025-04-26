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
    # First, examine the structure
    echo "Contents of current directory:"
    ls -la
    echo "Contents of code-server directory:"
    ls -la code-server-${version}-${platform}

    # Create output directory
    mkdir -p $out
    
    # Copy all files from the tarball as-is
    cp -r code-server-${version}-${platform}/* $out/
    
    # Look for the code-server executable or entry point
    echo "Looking for executables:"
    find $out -type f -executable | sort || echo "No executables found"
    echo "Looking for Node.js entry points:"
    find $out -name "*.js" | grep -i entry || echo "No entry.js found"
    
    # Create bin directory if it doesn't exist
    mkdir -p $out/bin
    
    # Create a wrapper script based on the structure we find
    if [ -f "$out/bin/code-server" ]; then
      echo "Found original code-server in bin, wrapping it..."
      mv $out/bin/code-server $out/bin/code-server-original
    elif [ -f "$out/code-server" ]; then
      echo "Found code-server in root, moving to bin..."
      mv $out/code-server $out/bin/code-server-original
    fi
    
    # Find an appropriate entry point
    ENTRY_POINT=""
    if [ -f "$out/out/node/entry.js" ]; then
      ENTRY_POINT="$out/out/node/entry.js"
    elif [ -f "$out/lib/node_modules/code-server/out/node/entry.js" ]; then
      ENTRY_POINT="$out/lib/node_modules/code-server/out/node/entry.js"
    else
      # Search for any entry.js file
      ENTRY_POINT=$(find $out -name "entry.js" | head -1 || echo "")
    fi
    
    # Create the wrapper script
    echo "Creating wrapper script with entry point: $ENTRY_POINT"
    cat > $out/bin/code-server << EOF
    #!/bin/sh
    
    # Set PATH to ensure all needed tools are available
    export PATH="${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.nodejs}/bin:\$PATH"
    
    if [ -f "$out/bin/code-server-original" ]; then
      # Use the original binary if available
      exec $out/bin/code-server-original "\$@"
    elif [ -n "$ENTRY_POINT" ]; then
      # Use node to run the entry point
      exec ${pkgs.nodejs}/bin/node "$ENTRY_POINT" "\$@"
    else
      echo "Error: Could not find code-server executable or entry point."
      echo "Available files:"
      find $out -type f -name "code-server*" || echo "No code-server files found"
      exit 1
    fi
    EOF
    
    chmod +x $out/bin/code-server
  '';

  meta = with pkgs.lib; {
    description = "VS Code in the browser";
    homepage = "https://github.com/coder/code-server";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
