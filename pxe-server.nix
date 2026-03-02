{ config, pkgs, ... }:

let
  # Placeholder derivation for our future Haskell-based Skellinux/LambdaOS kernel.
  lambdaOsKernel = pkgs.writeText "lambdaos.bin" "PURE_FP_KERNEL_PLACEHOLDER";

  # 1. Create the PXE Menu with ONLY LambdaOS
  pxeConfigFile = pkgs.writeText "default" ''
    DEFAULT lambdaos
    PROMPT 0
    TIMEOUT 10

    LABEL lambdaos
      MENU LABEL Boot LambdaOS (Pure FP Skellinux Kernel)
      KERNEL mboot.c32
      APPEND lambdaos.bin
  '';
in
{
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
      dhcp-host = "28:f1:0e:18:a8:20,192.168.68.146,lambdaos"; 
    };
  };

  # 2. Stage strictly the syslinux bootloaders, dependencies, and the LambdaOS kernel
  systemd.tmpfiles.rules = [
    "d /srv/tftpboot 0755 root root -"
    "d /srv/tftpboot/pxelinux.cfg 0755 root root -"
    "L+ /srv/tftpboot/pxelinux.0 - - - - ${pkgs.syslinux}/share/syslinux/pxelinux.0"
    "L+ /srv/tftpboot/ldlinux.c32 - - - - ${pkgs.syslinux}/share/syslinux/ldlinux.c32"
    "L+ /srv/tftpboot/mboot.c32 - - - - ${pkgs.syslinux}/share/syslinux/mboot.c32"
    "L+ /srv/tftpboot/libcom32.c32 - - - - ${pkgs.syslinux}/share/syslinux/libcom32.c32"
    "L+ /srv/tftpboot/libutil.c32 - - - - ${pkgs.syslinux}/share/syslinux/libutil.c32"
    "L+ /srv/tftpboot/lambdaos.bin - - - - ${lambdaOsKernel}"
    "L+ /srv/tftpboot/pxelinux.cfg/default - - - - ${pxeConfigFile}"
  ];

  networking.firewall.allowedUDPPorts = [ 67 68 69 4011 ];
}
