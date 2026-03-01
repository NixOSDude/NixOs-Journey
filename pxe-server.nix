{ config, pkgs, ... }:

let
  # 1. Define the Lab Identity and Logic
  myIdentity = { ... }: {
    networking.hostName = "nixlab";
    
    users.users.nixos.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGBaIvAyOc9ENX7xVIT+r8Odq+tbwy3Az+l3RvKbDPr scott.baker@gmail.com"
    ];

    # Automated Mount for the 1TB Lab Disk
    fileSystems."/mnt/lab" = {
      device = "/dev/disk/by-label/DEll_LAB";
      fsType = "ext4";
      options = [ "nofail" "rw" ];
    };

    # Lab Tools pre-installed in the RAM image
    environment.systemPackages = with pkgs; [
      htop
      pciutils
      git
      vim
    ];

    security.sudo.wheelNeedsPassword = false;
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };

  # 2. Build the Netboot image
  netboot = (import <nixpkgs/nixos/lib/eval-config.nix> {
    modules = [ 
      <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>
      myIdentity
    ];
  }).config.system.build;

  # 3. Create the PXE Menu
  pxeConfigFile = pkgs.writeText "default" ''
    DEFAULT nixos
    LABEL nixos
      SAY Booting nixlab (1TB Lab Mode) from Ultra 7...
      KERNEL bzImage
      APPEND initrd=initrd init=${netboot.toplevel}/init root=/dev/ram0 rw copytoram nomodeset
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
      
      # Static Lease for the Dell
      dhcp-host = "28:f1:0e:18:a8:20,192.168.68.146,nixlab";
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/tftpboot 0755 root root -"
    "d /srv/tftpboot/pxelinux.cfg 0755 root root -"
    "L+ /srv/tftpboot/pxelinux.0 - - - - ${pkgs.syslinux}/share/syslinux/pxelinux.0"
    "L+ /srv/tftpboot/ldlinux.c32 - - - - ${pkgs.syslinux}/share/syslinux/ldlinux.c32"
    "L+ /srv/tftpboot/bzImage - - - - ${netboot.kernel}/bzImage"
    "L+ /srv/tftpboot/initrd - - - - ${netboot.netbootRamdisk}/initrd"
    "L+ /srv/tftpboot/pxelinux.cfg/default - - - - ${pxeConfigFile}"
  ];

  networking.firewall.allowedUDPPorts = [ 67 68 69 4011 ];
}
