{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  # Optional: Automatically pull a model on startup so Hasxiom is ready
  # systemd.services.ollama.postStart = "${pkgs.ollama}/bin/ollama run deepseek-coder:6.7b";
}
