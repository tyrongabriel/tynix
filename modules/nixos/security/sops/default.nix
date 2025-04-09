{ config, lib, ... }:
with lib;
with lib.tynix;
let cfg = config.security.sops;
in {
  options.security.sops = with types; {
    enable = mkEnableOption "Whether to enable sop for secrets management.";
  };

  config = mkIf cfg.enable {
    sops = {
      # Hosts key file (User keys specified in home-manager)
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
