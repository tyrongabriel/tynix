{ lib, config, ... }:
with lib;
with lib.tynix;
let
  cfg = config.development.environment.direnv;
  zshEnabled = config.cli.shells.zsh.enable;
in {
  options.development.environment.direnv = with types; {
    enable = mkEnableOption "Enable direnv for automatic environment switching";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = ifThenElse zshEnabled true false;
      silent = true;
    };

    programs.zsh = mkIf zshEnabled {
      # Add hook
      initContent = ''
        eval "$(direnv hook zsh)"
      '';
      #oh-my-zsh.plugins = [ "direnv" ];

    };
  };
}
