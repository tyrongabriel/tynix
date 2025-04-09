{ lib, config, ... }:
with lib;
with lib.tynix;
let cfg = config.development.editors.neovim;
in {
  options.development.editors.neovim = with types; {
    enable = mkEnableOption "Enable neovim editor";
    defaultEditor = mkBoolOpt false "Use neovim as default editor";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };
  };
}
