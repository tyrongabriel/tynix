{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let
  cfg = config.suites.homelab;
  tailnet = "tail1c2108.ts.net";
in {
  options.suites.homelab = with types; {
    enable = mkEnableOption "Enable configurations every homelab machine needs";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    environment.variables = { TAILNET_NAME = tailnet; };
    services.tailscale.enable = true;
    # If my tailnet uses routing features etc. need to configure
    #services.tailscale.useRoutingFeatures = "both" | "server" | "client"

    # For dns certs in the tailnet, run
    # sudo tailscale cert ${HOSTNAME}.${TAILNET_NAME}
    # Or like me make this service
    systemd.services.update-tailscale-tls-cert = {
      description = "Execute my tailscale cert to get new https cert";
      environment = {
        HOSTNAME = config.networking.hostName; # The hostname of the machine
        TAILNET_NAME = tailnet;
      };
      serviceConfig = {
        User = "root"; # Or a less privileged user if appropriate
        Type = "oneshot"; # The service exits after executing the command
        ExecStart =
          "${pkgs.tailscale}/bin/tailscale cert \${HOSTNAME}.\${TAILNET_NAME}";
      };
    };

    systemd.timers.update-tailscale-tls-cert-timer = {
      description = "Run my tls update monthly";
      wantedBy = [ "timers.target" ];
      partOf = [ "update-tailscale-tls-cert.service" ];
      timerConfig = {
        Unit = "update-tailscale-tls-cert.service";
        OnCalendar = "monthly"; # Run at the beginning of each month (00:00)
        # You can be more specific, e.g., "03:15 1st * *" for 3:15 AM on the 1st of every month
        Persistent = true; # If the system was off, run the job soon after boot
      };
    };
  };
}
