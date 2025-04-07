{
  config,
  lib,
  ...
}:
with lib;
with lib.tynix;
let
  cfg = config.cli.programs.nh;
in
{
  options.cli.programs.nh = with lib; {
    enable = mkEnableOption "Enable nh for a better nix cli";
  };

  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/${config.user.name}/tynix";
    };
  };
}
