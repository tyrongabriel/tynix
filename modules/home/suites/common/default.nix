{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.suites.common;
in {
  options.suites.common = with types; {
    enable = mkEnableOption "Enable Common modules suite";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    cli.shells.zsh.enable = true;
    security.sops.enable = true;

    home.packages = with pkgs; [ curl btop fzf ];
  };
}
