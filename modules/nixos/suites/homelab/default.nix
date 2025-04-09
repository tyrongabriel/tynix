{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.suites.homelab;
in {
  options.suites.homelab = with types; {
    enable = mkEnableOption "Enable configurations every homelab machine needs";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    services.tynix.tailscale = {
      enable = true;
      useHttps = true;
      tailnet = "tail1c2108.ts.net";
    };
  };
}
