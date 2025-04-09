{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.cli.programs.nix-ld;
in {
  options.cli.programs.nix-ld = with types; {
    enable = mkEnableOption "Enable nix-ld for unpatched binaries";
    # Add more options here
  };

  config = lib.mkIf cfg.enable { programs.nix-ld = { enable = true; }; };
}
