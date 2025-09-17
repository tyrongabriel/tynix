{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.tynix.headscale;
in {
  options.tynix.headscale = with types; {
    enable = mkEnableOption "Enable module";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {

  };
}
