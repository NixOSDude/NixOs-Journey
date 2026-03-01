{ config, pkgs, ... }:

let
  netboot = (import <nixpkgs/nixos/lib/eval-config.nix> {
    modules = [ <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix> ];
  }).config.system.build;

  # This creates a REAL file in the Nix store. No truncation possible.
  pxeConfigFile = pkgs.writeText "default" ''
    DEFAULT nixos
    LABEL nixos
      SAY Booting Pure NixOS from Ultra 7...
      KERNEL bzImage
      APPEND initrd=initrd init=${netboot.toplevel}/init root=/dev/ram0 rw copytoram
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
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/tftpboot 0755 root root -"
    "d /srv/tftpboot/pxelinux.cfg 0755 root root -"
    "L+ /srv/tftpboot/pxelinux.0 - - - - ${pkgs.syslinux}/share/syslinux/pxelinux.0"
    "L+ /srv/tftpboot/ldlinux.c32 - - - - ${pkgs.syslinux}/share/syslinux/ldlinux.c32"
    "L+ /srv/tftpboot/bzImage - - - - ${netboot.kernel}/bzImage"
    "L+ /srv/tftpboot/initrd - - - - ${netboot.netbootRamdisk}/initrd"
    
    # We point the 'default' config to our perfectly pre-built file
    "L+ /srv/tftpboot/pxelinux.cfg/default - - - - ${pxeConfigFile}"
  ];

  networking.firewall.allowedUDPPorts = [ 67 68 69 4011 ];
}
