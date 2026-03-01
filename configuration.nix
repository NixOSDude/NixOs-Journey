{ config, pkgs, lib, ... }:

{
  imports = [     
    ./hardware-configuration.nix
    ./users.nix
    ./nvidia.nix
    ./pxe-server.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/Phoenix";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = { layout = "us"; variant = ""; };

  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  # --- Sovereign Node Environment ---
  nixpkgs.config.allowUnfree = true;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    direnv
    nix-direnv
    vscodium
    rsync
    htop
    pciutils
    curl
    lsof
    attr
  ];

  services.openssh.enable = true;

  programs.bash = {
    interactiveShellInit = ''
      eval "$(direnv hook bash)"
    '';
    shellAliases = {
      nix-switch = "sudo nixos-rebuild switch";
      nix-clean = "sudo nix-collect-garbage -d";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  networking = {
    hostName = "NixOsEng";
    networkmanager.enable = false;
    useDHCP = false;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 9000 ];
      allowedUDPPorts = [ 9001 ];
    };

    interfaces.enp129s0.ipv4.addresses = [
      {
        address = "192.168.0.53";
        prefixLength = 22;
      }
      {
        address = "192.168.68.50";
        prefixLength = 24;
      }
    ];
    
    defaultGateway = "192.168.0.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  system.stateVersion = "25.11";
}
