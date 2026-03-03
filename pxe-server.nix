{ config, pkgs, ... }:

let
  # ---------------------------------------------------------------------------
  # LambdaOS Kernel Source
  # ---------------------------------------------------------------------------
  # We are pulling the compiled 64-bit ELF binary directly from our local 
  # build directory. Nix will copy this into the immutable Nix store.
  lambdaOsKernel = /home/nixdude/LambdaOS/build/lambdaos.bin;

  # ---------------------------------------------------------------------------
  # PXE Boot Menu Configuration
  # ---------------------------------------------------------------------------
  pxeConfigFile = pkgs.writeText "default" ''
    DEFAULT lambdaos
    PROMPT 0
    TIMEOUT 10

    LABEL lambdaos
      MENU LABEL Boot LambdaOS (Pure FP Sovereign Machine)
      KERNEL mboot.c32
      APPEND lambdaos.bin
  '';
in
{
  # ---------------------------------------------------------------------------
  # DNSMasq / TFTP Configuration
  # ---------------------------------------------------------------------------
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "enp129s0";
      bind-interfaces = true;
      enable-tftp = true;
      tftp-root = "/srv/tftpboot";
      dhcp-range = "192.168.68.100,192.168.68.200,12h";
      dhcp-boot = "pxelinux.0";
      tftp-mtu = "1468";
      # Dell Test PC MAC Address mapping
      dhcp-host = "28:f1:0e:18:a8:20,192.168.68.146,lambdaos";  
    };
  };

  # ---------------------------------------------------------------------------
  # TFTP Directory Staging
  # ---------------------------------------------------------------------------
  systemd.tmpfiles.rules = [
    "d /srv/tftpboot 0755 root root -"
    "d /srv/tftpboot/pxelinux.cfg 0755 root root -"
    
    # Syslinux Dependencies
    "L+ /srv/tftpboot/pxelinux.0 - - - - ${pkgs.syslinux}/share/syslinux/pxelinux.0"
    "L+ /srv/tftpboot/ldlinux.c32 - - - - ${pkgs.syslinux}/share/syslinux/ldlinux.c32"
    "L+ /srv/tftpboot/mboot.c32 - - - - ${pkgs.syslinux}/share/syslinux/mboot.c32"
    "L+ /srv/tftpboot/libcom32.c32 - - - - ${pkgs.syslinux}/share/syslinux/libcom32.c32"
    "L+ /srv/tftpboot/libutil.c32 - - - - ${pkgs.syslinux}/share/syslinux/libutil.c32"
    
    # LambdaOS Immutable Artifacts
    "L+ /srv/tftpboot/lambdaos.bin - - - - ${lambdaOsKernel}"
    "L+ /srv/tftpboot/pxelinux.cfg/default - - - - ${pxeConfigFile}"
  ];

  networking.firewall.allowedUDPPorts = [ 67 68 69 4011 ];
}
