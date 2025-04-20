{ lib, config, ... }:
with lib;
with lib.tynix;
let cfg = config.services.tynix;
in {
  options.services.tynix = with types; {
    enable = mkEnableOption "Enable tynix services";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    #configuration;
  };
}
