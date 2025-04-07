{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.suites.server;
in {
  options.suites.server = with types; {
    enable = mkEnableOption "Enable the server suite";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    # Enable common suite
    suites.common.enable = true;

  };
}
