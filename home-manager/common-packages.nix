{ pkgs }:

with pkgs; [
  # Core tools
  python3Minimal
  go
#  rustc
#  cargo
  nodejs_20

  # Dev tools
  claude-code
  git
#  git-lfs
  gh
  gitAndTools.delta
#  nixpkgs-fmt
  uv
  ruff
#  fd
  ripgrep
  bat
#  jq
  neovim
  aider-chat
#  docker-compose
#  tree
  wget
#  fzf

  # Shell tools
  fish
  tmux
  starship

  # Python packages
  python312Packages.pip
  python312Packages.virtualenv
  python312Packages.black
  python312Packages.mypy
  python312Packages.ipython

  # Language servers
#  pyright
#  gopls
#  rust-analyzer
#  nodePackages.typescript-language-server
#  nodePackages.vscode-langservers-extracted
]
