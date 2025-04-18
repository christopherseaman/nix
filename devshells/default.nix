{ pkgs }:

pkgs.mkShell {
  packages = with pkgs; [
    # Python core
    python311
    python311Packages.pip
    python311Packages.virtualenv
    
    # Development tools
    python311Packages.black        # Code formatting
    python311Packages.ruff         # Fast linter
    python311Packages.mypy         # Type checking
    python311Packages.uv           # Fast package installer
    python311Packages.ipython      # Enhanced interactive shell
    
    # Golang 
    go
    gopls
    
    # Development utilities
    git
    nixpkgs-fmt                    # Nix formatter
    nil                            # Nix language server
    
    # IDE support
    vscode.fhs
  ];
  
  shellHook = ''
    # Python virtual environment setup
    if [ ! -d .venv ]; then
      uv venv
    fi
    source .venv/bin/activate
    
    # Go setup
    export GOPATH=$HOME/go
  '';
}
