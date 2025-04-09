{ config, lib, ... }:
with lib;
with lib.tynix;
let cfg = config.user;
in {
  options.user = with types; {
    enable = mkOpt bool false "Whether to configure the user account.";
    home = mkOpt (nullOr str) "/home/${cfg.name}" "The user's home directory.";
    name = mkOpt (nullOr str) config.snowfallorg.user.name "The user account.";
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = cfg.name != null;
      message = "user.name must be set";
    }];

    home = {
      homeDirectory = mkDefault cfg.home;
      username = mkDefault cfg.name;
    };
  };
}
