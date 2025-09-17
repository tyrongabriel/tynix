{ lib, config, ... }:
with lib;
with lib.tynix;
#let cfg = config.tynix;in
{
  options.tynix = with types;
    {
      #selfBuildDeployment = mkOpt bool false
      #  "Enable self-building deployments -> remote build will be active for this device.";
      # Add more options here
    };

  config = {
    #configuration;
  };
}
