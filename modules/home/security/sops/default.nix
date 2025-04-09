{ config, lib, inputs, ... }:
with lib;
with lib.tynix;
let cfg = config.security.sops;
in {
  options.security.sops = with types; {
    enable = mkEnableOption "Whether to enable sop for secrets management.";
  };

  imports = with inputs; [ sops-nix.homeManagerModules.sops ];

  config = mkIf cfg.enable {
    sops = {
      age = {
        generateKey = true;
        keyFile = "/home/${config.user.name}/.config/sops/age/keys.txt";
        sshKeyPaths = [ "/home/${config.user.name}/.ssh/id_ed25519" ];
      };

      defaultSymlinkPath = "/run/user/1000/secrets";
      defaultSecretsMountPoint = "/run/user/1000/secrets.d";
    };
  };
}
