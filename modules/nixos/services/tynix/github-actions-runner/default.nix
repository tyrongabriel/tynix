{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
with lib.types;
let cfg = config.services.tynix.github-actions-runner;
in {
  options.services.tynix.github-actions-runner = with types; {
    enable = mkEnableOption "Enable Github actions runner";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.githubToken = { sopsFile = ../secrets.yml; };
    # File at: config.sops.secrets.github.path;
    #configuration;
  };
}
