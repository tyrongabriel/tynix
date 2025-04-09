{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.suites.development;
in {
  options.suites.development = with types; {
    enable = mkEnableOption "Enable development suite";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    ## CLI Configurations ##
    cli = {
      shells.zsh.enable = true; # ZSH Shell
      programs = {
        nix-index.enable = true;
        yazi.enable = true;
      };
    };

    ## Development Tools ##
    development = {
      editors.neovim = {
        enable = true;
        defaultEditor = true;
      };

      environment = {
        direnv.enable = true;
        devbox.enable = true;
      };
    };

    ## Extra Packages ##
    home.packages = with pkgs; [
      curl
      btop
      fzf

    ];

  };
}
