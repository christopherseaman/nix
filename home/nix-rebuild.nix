{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (writeScriptBin "nix-rebuild" ''
      #!/usr/bin/env bash
      set -e  # Exit on error
      
      # Set correct encoding for terminal
      export LC_ALL=en_US.UTF-8
      export LANG=en_US.UTF-8

      REPO_PATH="''${1:-/etc/nixos}"  # Default to /etc/nixos if not specified
      REMOTE="''${2:-origin}"         # Default to 'origin' if not specified 
      BRANCH="''${3:-main}"           # Default to 'main' if not specified
      
      # Function to show usage info
      show_usage() {
        echo "Usage: $(basename $0) [REPO_PATH] [REMOTE] [BRANCH]"
        echo "  REPO_PATH: Path to your NixOS config repository (default: /etc/nixos)"
        echo "  REMOTE:    Git remote to push to (default: origin)"
        echo "  BRANCH:    Git branch to push (default: main)"
        echo ""
        echo "Example: $(basename $0) /etc/nixos origin main"
        echo ""
        echo "This command will:"
        echo "  1. Save changes with a temporary commit"
        echo "  2. Rebuild your NixOS configuration"
        echo "  3. If successful, amend commit with success message and push"
      }

      # Show help if requested
      if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_usage
        exit 0
      fi

      # Check if we're in /etc/nixos or another flake directory
      if [[ ! -f "$REPO_PATH/flake.nix" ]]; then
        echo "Error: No flake.nix found in $REPO_PATH"
        exit 1
      fi

      # Change to the repository directory
      cd "$REPO_PATH" || exit 1
      
      # Get hostname for the flake target
      HOSTNAME=$(hostname)
      
      # Check if there are uncommitted changes
      if [[ -n "$(git status --porcelain)" ]]; then
        echo "📝 Changes detected, creating temporary commit..."
        git add .
        
        # Check if previous commit message was "working..."
        PREV_MSG=$(git log -1 --pretty=%B)
        if [[ "$PREV_MSG" == "working..." ]]; then
          echo "📝 Amending previous 'working...' commit"
          git commit --amend --no-edit
        else
          echo "📝 Creating new temporary commit"
          git commit -m "working..."
        fi
      else
        echo "✅ No changes to commit."
      fi

      echo "🔄 Rebuilding NixOS configuration for $HOSTNAME..."

      # Run the nixos-rebuild command
      if sudo nixos-rebuild switch --flake "$REPO_PATH#$HOSTNAME"; then
        echo "✅ NixOS rebuild successful!"
        
        # Check if the working commit exists (if we made changes)
        if git log -1 --pretty=%B | grep -q "working..."; then
          echo "📝 Amending commit with success message..."
          
          # Create success commit message with hostname and date
          SUCCESS_MSG="auto-commit: Successful rebuild on $HOSTNAME ($(date '+%Y-%m-%d %H:%M:%S'))"
          git commit --amend -m "$SUCCESS_MSG"
          echo "✅ Commit amended with message: $SUCCESS_MSG"
        fi
        
        # Push to git remote
        echo "🦾 Pushing to $REMOTE/$BRANCH..."
        if git push "$REMOTE" "$BRANCH" --force-with-lease; then
          echo "🚀 Git push successful!"
        else
          echo "⚠️ Git push failed. You may need to push manually."
          exit 1
        fi
      else
        echo "❌ NixOS rebuild failed. The temporary commit remains for debugging."
        exit 1
      fi
    '')

    (writeScriptBin "nix-rebuild-simple" ''
      #!/usr/bin/env bash
      set -e
      
      # Set correct encoding
      export LC_ALL=en_US.UTF-8
      export LANG=en_US.UTF-8
      
      HOSTNAME=$(hostname)
      echo "🔄 Rebuilding NixOS configuration for $HOSTNAME..."
      sudo nixos-rebuild switch --flake "/etc/nixos#$HOSTNAME"
      echo "✅ NixOS rebuild completed."
    '')
  ];
}
