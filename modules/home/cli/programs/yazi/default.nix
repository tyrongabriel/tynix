{ lib, config, ... }:
with lib;
with lib.tynix;
let cfg = config.cli.programs.yazi;
in {
  options.cli.programs.yazi = with types; {
    enable = mkEnableOption "Enable yazi cli based file explorer";
    # Add more options here
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = lib.mkDefault true;
      enableZshIntegration = true;
      # Extra settings
      settings = {
        manager = { linemode = "mtime"; };
        # Configure opener
        # opener = {
        #   # Editor list
        #   edit = [
        #     {
        #       run = "nvim";
        #       for = "unix";
        #     }
        #   ];
        # };
      };

    };
  };
}
