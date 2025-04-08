{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.services.ssh;
in {
  options.services.ssh = with types; {
    enable = mkEnableOption "Enable SSH with OpenSSH";
    authorizedKeys = mkOpt (listOf str) [ ]
      "SSH public keys to be added to the user's authorized_keys file.";
  };

  config = lib.mkIf cfg.enable {
    # Warn the user that he should be using ssh keys
    warnings = if (cfg.authorizedKeys == [ ]) then [''
      No ssh keys authorized, allowing password login!
      You should set `services.ssh.authorizedKeys` to a list of ssh keys.
    ''] else
      [ ];

    # Configure openssh service
    services.openssh = {
      enable = true;
      ports = [ 22 ];

      settings = {
        PasswordAuthentication =
          if (cfg.authorizedKeys == [ ]) then true else false;
        #StreamLocalBindUnlink = "yes";
        GatewayPorts = "clientspecified";
      };
    };
    users.users.${config.user.name} = {
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
  };
}
