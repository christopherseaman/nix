# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  
  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "carnac"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = false;
  # OR
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  #  pulse.enable = true;  # PulseAudio compatibility
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  programs.fish.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {

    root = {
      # change this to your ssh key
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7GSxAtUo0zgXEnLZiK30LdAIy3llH/p7jSehl431rh root@hivemind"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhGXUM74cYjfKWK559WXpOMQ2vjB7dmz3/uC2M52RWhkzsJljmG5WLiTz0cejQCcnG7T4QIONE0qMW4RiE2HiJcHoGo6S0mAgsN7A0XhRIJmZhmOnL2PIYZ5lh8dM5ya74dFeaRz9XQmod4//Q2LsaCJDaXNieeyvLifXuHTfFcqWxbUOfh0993beLUuSzRX5tD1R9CNyfOnpHXlGDxB/oNNTn6QF8ck9RiDtYl2S95QQo+tB2A7DwI+pVl9rbZ41vyd+cn3Vtvtg6dtRGpNNWeRE9Cr/MLmc6GzcT1hWdXU1dSa8J7DQ80bJX6XwClkeTeSMpwWZN4b0UguQcnVav"
      ];
    };

    # UNCOMMENT the following to enable the nixos user
    christopher = {
      isNormalUser = true; 
      shell = pkgs.fish; 
      description = "nixos user"; 
      extraGroups = [ 
        "networkmanager" 
        "wheel" 
        "docker"
      ]; 
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO7GSxAtUo0zgXEnLZiK30LdAIy3llH/p7jSehl431rh root@hivemind"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDhGXUM74cYjfKWK559WXpOMQ2vjB7dmz3/uC2M52RWhkzsJljmG5WLiTz0cejQCcnG7T4QIONE0qMW4RiE2HiJcHoGo6S0mAgsN7A0XhRIJmZhmOnL2PIYZ5lh8dM5ya74dFeaRz9XQmod4//Q2LsaCJDaXNieeyvLifXuHTfFcqWxbUOfh0993beLUuSzRX5tD1R9CNyfOnpHXlGDxB/oNNTn6QF8ck9RiDtYl2S95QQo+tB2A7DwI+pVl9rbZ41vyd+cn3Vtvtg6dtRGpNNWeRE9Cr/MLmc6GzcT1hWdXU1dSa8J7DQ80bJX6XwClkeTeSMpwWZN4b0UguQcnVav"
      ];
    };

  };
  # programs.firefox.enable = true;

  # allow unfree packages to be installed
  nixpkgs.config = {
    allowUnfree = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # System tools
    git
    wget
    neovim
    caddy
    starship

    # Development
    # vscode
    # code-server

    # Fonts
    _0xproto
    source-code-pro
    source-serif
    source-sans
  ];


  # Set the default editor to vim
  environment.variables.EDITOR = "nvim";
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };
  
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .

  system.stateVersion = "24.11";

}

