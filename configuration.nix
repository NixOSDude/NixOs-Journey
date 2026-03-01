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

  networking.networkmanager.enable = true;

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

  system.stateVersion = "25.11";
  networking.hostName = "NixOsEng";
  networking.firewall.allowedTCPPorts = [ 22 80 443 9000 ];
  networking.firewall.allowedUDPPorts = [ 9001 ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
