{ config, pkgs, ...  }:

{

# Enable graphics driver
hardware.graphics.enable = true;

# Load nvidia driver for Xorg and Wayland (Plasma uses Wayland)
services.xserver.videoDrivers = ["nvidia"];

hardware.nvidia = {
  # Modesetting is required for Plasma Wayland
  modesetting.enable = true;

  # Nvidia power management. Experimental, and can cause sleep issues.
  powerManagement.enable = false;
  powerManagement.finegrained = false;

  # Use the NVidia open source kernel module (not to be confused with nouveau)
  # This is usually preferred for Turing and later (your 3060 is Ampere)
  open = false;

  # Enable the Nvidia settings menu
  nvidiaSettings = true;

  # Select the appropriate driver version
  package = config.boot.kernelPackages.nvidiaPackages.stable;
};

}
