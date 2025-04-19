# /etc/nixos/packages/code-server/default.nix
{ pkgs, code-server-src }:

let
  nodejs = pkgs.nodejs_20;
  typescript = pkgs.nodePackages.typescript;

  buildInputs = with pkgs; [
    python3 pkg-config git openssl
    libsecret libkrb5 xorg.libX11 xorg.libxkbfile
    gcc gnumake typescript
  ];
in pkgs.buildNpmPackage {
  pname = "code-server";
  version = code-server-src.shortRev or "git";

  src = code-server-src;
  npmDepsHash = "sha256-xgL4Uh0jUlEIIVU0V0Hv5G1G/T8l5qL9tzJo3doXTVg=";

  nodejs = nodejs;
  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = buildInputs;
  
  # Fix TypeScript type error
  postPatch = ''
    sed -i 's/return raw ? JSON.parse(raw) : {}/return raw ? JSON.parse(raw) : {} as T/' src/node/settings.ts
  '';

  buildPhase = ''
    runHook preBuild

    # Create required symlinks
    (
      cd lib/vscode
      ln -s ../../../node_modules node_modules.asar
      mkdir -p bin/remote-cli bin/helpers
    )

    # Rebuild native modules
    pushd node_modules/argon2
    npm run install
    popd

    # Find and rebuild other native modules
    find node_modules -type f -name "binding.gyp" | while read -r module_path; do
      module_dir=$(dirname "$module_path")
      pushd "$module_dir"
      if [ -f "package.json" ]; then
        if grep -q '"install"' package.json; then
          npm run install
        elif grep -q '"build"' package.json; then
          npm run build
        fi
      fi
      popd
    done

    # Compile TypeScript
    export PATH="${typescript}/bin:$PWD/node_modules/.bin:$PATH"
    tsc --build tsconfig.json

    # Create release structure
    mkdir -p release-standalone/bin
    mkdir -p release-standalone/lib/lib/vscode
    
    # Copy required files
    cp -r out release-standalone/lib/
    cp -r node_modules release-standalone/lib/
    cp package.json release-standalone/lib/
    
    # Create vscode package.json if needed
    if [ -f lib/vscode/package.json ]; then
      cp lib/vscode/package.json release-standalone/lib/lib/vscode/
    else
      echo '{"name":"code-server-vscode","version":"1.0.0"}' > release-standalone/lib/lib/vscode/package.json
    fi
    
    # Create launcher script
    cat > release-standalone/bin/code-server <<EOF
    #!/usr/bin/env bash
    cd "\$(dirname "\$(readlink -f "\$0")")/../lib" || exit 1
    exec ${nodejs}/bin/node out/node/entry.js "\$@"
    EOF
    chmod +x release-standalone/bin/code-server
    
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r release-standalone/* $out/
    runHook postInstall
  '';

  runtimeDependencies = [ nodejs ];

  meta = with pkgs.lib; {
    description = "VS Code in the browser";
    homepage = "https://github.com/coder/code-server";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
