{ lib, config, ... }:
with lib;
with lib.tynix;
let cfg = config.suites.server;
in {
  options.suites.server = with types; {
    enable = mkEnableOption "Enable server suite";
    # Add more options here
  };

  config = lib.mkIf cfg.enable { suites.common.enable = true; };
}
