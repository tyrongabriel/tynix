{ config, lib, ... }:
with lib;
with lib.tynix;
let cfg = config.user;
in {
  options.user = with types; {
    name = mkOpt str "haseeb" "The name of the user's account";
    initialPassword = mkOpt str "1" "The initial password to use";
    extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { } "Extra options passed to users.users.<name>";
    authorizedKeys = mkOpt (listOf str) [ ]
      "SSH public keys to be added to the user's authorized_keys file.";
    passwordlessSudo =
      mkOpt bool false "Whether to allow passwordless sudo for the user.";
    trustedUser = mkOpt bool false
      "Whether the user should be added to the trusted-users list of nix";
  };

  config = {
    users.mutableUsers = false;
    nix.settings.trusted-users = mkIf cfg.trustedUser [ "${cfg.name}" ];
    ## For whell group (unused) ##
    # security.sudo.wheelNeedsPassword = false;
    ## For one specific user ##
    security.sudo.extraRules = mkIf cfg.passwordlessSudo [{
      users = [ cfg.name ];
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
    }];

    users.users.${cfg.name} = {
      isNormalUser = true;
      inherit (cfg) name initialPassword;
      home = "/home/${cfg.name}";
      group = "users";

      # TODO: set in modules
      extraGroups = [
        "wheel"
        "audio"
        "sound"
        "video"
        "networkmanager"
        "input"
        "tty"
        "podman"
        "kvm"
        "libvirtd"
      ] ++ cfg.extraGroups;

      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    } // cfg.extraOptions;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };

  };
}
