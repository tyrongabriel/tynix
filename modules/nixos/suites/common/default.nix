{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.suites.common;
in {
  options.suites.common = with types; {
    enable = mkEnableOption "Enable the common suite";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    services.ssh.enable = true;
    security.sops.enable = true;
    environment.systemPackages = with pkgs; [ comma ];
  };
}
