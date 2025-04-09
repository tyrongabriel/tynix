{ lib, config, ... }:
with lib;
with lib.tynix;
let cfg = config.suites.desktop;
in {
  options.suites.desktop = with types; {
    enable = mkEnableOption "Enable desktop suite";
    # Add more options here
  };

  config = lib.mkIf cfg.enable { suites.common.enable = true; };
}
