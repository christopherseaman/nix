# configuration.nix
{ config, lib, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix 
  ];

  # System basics
  system.stateVersion = "24.11"; # Do not change this value!
  nixpkgs.config.allowUnfree = true;
	 
  # Nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking = {
    hostName = "carnac";
    networkmanager.enable = true;
    proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    firewall.enable = false;
  };

  # Localization
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  # Input devices
  services.libinput.enable = true;

  # Shell
  programs.fish.enable = true;

  # Security
  security.sudo.wheelNeedsPassword = false;
  
  # SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # User accounts
  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7GSxAtUo0zgXEnLZiK30LdAIy3llH/p7jSehl431rh root@hivemind"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhGXUM74cYjfKWK559WXpOMQ2vjB7dmz3/uC2M52RWhkzsJljmG5WLiTz0cejQCcnG7T4QIONE0qMW4RiE2HiJcHoGo6S0mAgsN7A0XhRIJmZhmOnL2PIYZ5lh8dM5ya74dFeaRz9XQmod4//Q2LsaCJDaXNieeyvLifXuHTfFcqWxbUOfh0993beLUuSzRX5tD1R9CNyfOnpHXlGDxB/oNNTn6QF8ck9RiDtYl2S95QQo+tB2A7DwI+pVl9rbZ41vyd+cn3Vtvtg6dtRGpNNWeRE9Cr/MLmc6GzcT1hWdXU1dSa8J7DQ80bJX6XwClkeTeSMpwWZN4b0UguQcnVav"
      ];
    };

    christopher = {
      isNormalUser = true; 
      shell = pkgs.fish; 
      description = "Christopher Seaman"; # Updated description
      extraGroups = [ "networkmanager" "wheel" "docker" ]; 
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7GSxAtUo0zgXEnLZiK30LdAIy3llH/p7jSehl431rh root@hivemind"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhGXUM74cYjfKWK559WXpOMQ2vjB7dmz3/uC2M52RWhkzsJljmG5WLiTz0cejQCcnG7T4QIONE0qMW4RiE2HiJcHoGo6S0mAgsN7A0XhRIJmZhmOnL2PIYZ5lh8dM5ya74dFeaRz9XQmod4//Q2LsaCJDaXNieeyvLifXuHTfFcqWxbUOfh0993beLUuSzRX5tD1R9CNyfOnpHXlGDxB/oNNTn6QF8ck9RiDtYl2S95QQo+tB2A7DwI+pVl9rbZ41vyd+cn3Vtvtg6dtRGpNNWeRE9Cr/MLmc6GzcT1hWdXU1dSa8J7DQ80bJX6XwClkeTeSMpwWZN4b0UguQcnVav"
      ];
    };
  };

  # System packages
  environment = {
    systemPackages = with pkgs; [
      # System tools
      git
      wget
      caddy
      # Remove user-specific packages like neovim, starship, fonts
    ];
  };
}
