{ lib, config, ... }:
with lib;
with lib.tynix;
let cfg = config.suites.common;
in {
  options.suites.common = with types; {
    enable = mkEnableOption "Enable Common modules suite";
    # Add more options here
  };

  config = lib.mkIf cfg.enable { security.sops.enable = true; };
}
