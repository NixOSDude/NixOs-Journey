{ config, pkgs, ... }:

let
  # 1. Define your Identity and Lab Logic
  myIdentity = { ... }: {
    # Injects your Golden Ticket SSH key for passwordless access
    users.users.nixos.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGBaIvAyOc9ENX7xVIT+r8Odq+tbwy3Az+l3RvKbDPr scott.baker@gmail.com"
    ];
    
    # Reduces hand strain: No password required for sudo commands
    security.sudo.wheelNeedsPassword = false;

    # Automated Mount for the 1TB Lab Disk
    # This looks for the label "DEll_LAB" we are about to create
    fileSystems."/mnt/lab" = {
      device = "/dev/disk/by-label/DEll_LAB";
      fsType = "ext4";
      options = [ "nofail" "rw" ];
    };

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };

  # 2. Build the Netboot image with the Identity Layer
  netboot = (import <nixpkgs/nixos/lib/eval-config.nix> {
    modules = [ 
      <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>
      myIdentity
    ];
  }).config.system.build;

  # 3. Create the PXE Menu file in the Nix Store
  pxeConfigFile = pkgs.writeText "default" ''
    DEFAULT nixos
    LABEL nixos
      SAY Booting Sovereign NixOS (Lab Mode) from Ultra 7...
      KERNEL bzImage
      APPEND initrd=initrd init=${netboot.toplevel}/init root=/dev/ram0 rw copytoram nomodeset
  '';
in
{
  # Networking & TFTP Services
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
      
      # Static Lease: Ensures the Dell always stays at .146
      dhcp-host = "28:f1:0e:18:a8:20,192.168.68.146";
    };
  };

  # System Automation: Symlinking the Build to the TFTP Root
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
