{ lib, config, ... }:
with lib;
with lib.tynix;
let cfg = config.services.tynix.adguardhome;
in {
  options.services.tynix.adguardhome = with types; {
    enable = mkEnableOption "Enable AdguardHome DNS";
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkForce {
      enable = true;
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };

    services.adguardhome = {
      enable = true;
      openFirewall = true; # Dashboard ports
      allowDHCP = true;
      port = 3000; # Dashboard
    };

    services = {
      tailscale.permitCertUid = "traefik";

      ## Configure Traefik for service ##
      traefik = {
        dynamicConfigOptions = {
          http = {
            ## Configure traefik service ##
            services = {
              ## Enter all servers for load balancing ##
              adguard.loadBalancer.servers =
                [{ url = "http://localhost:3000"; }];
            };

            ## Configure routing ##
            routers = {
              adguard = {
                entryPoints = [ "websecure" ]; # Configure entrypoints
                rule =
                  "Host(`adguard.tyrongabriel.com`) || Host(`adguard.home.tyrongabriel.com`)"; # Rule for which domain to route to AdguardHome
                service = "adguard"; # Service name
                tls.certResolver = "dns-cloudflare";
                #middlewares = [ "authentik" ]; # SSO with Authentik
              };
            };
          };
        };
      };
    };
  };
}
