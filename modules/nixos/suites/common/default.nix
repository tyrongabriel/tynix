{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.suites.common;
in {
  options.suites.common = with types; {
    enable = mkEnableOption "Enable the common suite";
    # Add more options here
  };

  config = mkIf cfg.enable {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    programs.zsh.enable = true; # Enable zsh
    cli.programs = {
      nh.enable = true; # Enable a better nix command
      nix-ld.enable = true; # Enable nix-ld for unpatched binaries
    };
    locale.enable = mkDefault true; # Enable default locale for Austrian stuff
    services.ssh.enable = true; # Enable openssh server
    security.sops.enable = true;
    environment.systemPackages = with pkgs; [ comma iputils git ];
  };
}
