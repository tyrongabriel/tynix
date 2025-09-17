{ lib, config, inputs, ... }:
with lib;
with lib.tynix;
let
  cfg = config.cli.programs.nix-index;
  zshEnabled = config.cli.shells.zsh.enable;
in {
  options.cli.programs.nix-index = with types; {
    enable = mkEnableOption "Enable nix-index (primarily for comma to work)";
    # Add more options here
  };
  imports = with inputs; [ nix-index-database.homeModules.nix-index ];

  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
      enableZshIntegration = ifThenElse zshEnabled true false;
      enableBashIntegration = ifThenElse zshEnabled false true;
    };
    programs.nix-index-database.comma.enable = true;
  };
}
