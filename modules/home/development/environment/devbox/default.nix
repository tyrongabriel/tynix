{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.development.environment.devbox;
in {
  options.development.environment.devbox = with types; {
    enable = mkEnableOption "Enable devbox developer environments";
    # Add more options here
  };

  config = lib.mkIf cfg.enable { home.packages = with pkgs; [ devbox ]; };
}
