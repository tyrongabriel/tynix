{ lib, config, ... }:
with lib;
with lib.tynix;
let
  cfg = config.locale;
in
{
  options.locale = with types; {
    enable = mkEnableOption "Enable locale";
    timeZone = mkOpt str "Europe/Vienna";
  };

  config = lib.mkIf cfg.enable {
    # Set your time zone.
    time.timeZone = "Europe/Vienna"; # "Europe/Vienna";

    # For time format in windows dualboot
    time.hardwareClockInLocalTime = mkDefault true;

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_AT.UTF-8";
      LC_IDENTIFICATION = "de_AT.UTF-8";
      LC_MEASUREMENT = "de_AT.UTF-8";
      LC_MONETARY = "de_AT.UTF-8";
      LC_NAME = "de_AT.UTF-8";
      LC_NUMERIC = "de_AT.UTF-8";
      LC_PAPER = "de_AT.UTF-8";
      LC_TELEPHONE = "de_AT.UTF-8";
      LC_TIME = "de_AT.UTF-8";
    };

    console.useXkbConfig = true;
    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "at";
      variant = "nodeadkeys";
      options = "caps:escape";
    };
  };
}
