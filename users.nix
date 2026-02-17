{ config, pkgs, ... }:

{
  users.users.nixdude = {
    isNormalUser = true;
    description = "NixDude";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      git
      direnv
      # Your FP Tools are already in your project flake, 
      # so we keep this list lean.
    ];
  };
}
