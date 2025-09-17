{ lib, config, ... }:
with lib;
with lib.tynix;
let cfg = config.suites.homelab;
in {
  options.suites.homelab = with types; {
    enable = mkEnableOption "Enable configurations every homelab machine needs";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    # Key for tailscale auth to automatically connect host for homelab
    sops.secrets.homelab-tailscale-auth-key = {
      sopsFile = ../../services/secrets.yaml;
    };
    services.tynix.tailscale = {
      enable = true;
      useHttps = true;
      tailnet = "tail1c2108.ts.net";
      authKeyFile = config.sops.secrets.homelab-tailscale-auth-key.path;
    };
  };
}
