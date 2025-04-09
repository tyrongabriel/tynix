{ lib, config, ... }:
with lib;
with lib.tynix;
let
  cfg = config.services.ssh;
  userAuthKeys =
    config.users.users.${config.user.name}.openssh.authorizedKeys.keys;
in {
  options.services.ssh = with types; {
    enable = mkEnableOption "Enable SSH with OpenSSH";
    rootLogin = mkOpt (enum [
      "yes"
      "without-password"
      "prohibit-password"
      "forced-commands-only"
      "no"
    ]) "yes" "Settings to permit root login via ssh";
  };

  config = lib.mkIf cfg.enable {
    # Warn the user that he should be using ssh keys
    warnings = if (userAuthKeys == [ ]) then [''
      No ssh keys authorized, allowing password login!
      You should set `services.ssh.authorizedKeys` to a list of ssh keys.
    ''] else
      [ ];

    # Configure openssh service
    services.openssh = {
      enable = true;
      ports = [ 22 ];

      settings = {
        PasswordAuthentication = if (userAuthKeys == [ ]) then true else false;
        #StreamLocalBindUnlink = "yes";
        GatewayPorts = "clientspecified";
        PermitRootLogin = cfg.rootLogin;
      };
    };
  };
}
