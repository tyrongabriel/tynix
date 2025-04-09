{ lib, config, ... }:
with lib;
with lib.tynix;
let cfg = config.services.tynix.adguardhome;
in {
  options.services.tynix.adguardhome = with types; {
    enable = mkEnableOption "Enable AdguardHome DNS";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkForce {
      enable = true;
      allowedUDPPorts = [ 53 ];

      allowedTCPPorts = [ 53 ];
    };

    services.adguardhome = {
      enable = true;
      openFirewall = true;
      allowDHCP = true;
    };
  };
}
