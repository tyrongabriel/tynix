{ config, lib, ... }:
with lib;
let cfg = config.services.tynix.traefik;
in {
  options.services.tynix.traefik = {
    enable = mkEnableOption "Enable traefik";
  };

  config = mkIf cfg.enable {
    ## Open Ports ##
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    systemd.services.traefik = {
      environment = { CF_API_EMAIL = "tyron.gabriel04@gmail.com"; };
      serviceConfig = {
        EnvironmentFile = [ config.sops.secrets.cloudflare_api_key.path ];
      };
    };

    sops.secrets.cloudflare_api_key = { sopsFile = ../secrets.yaml; };

    services = {
      tailscale.permitCertUid = "traefik";

      traefik = {
        enable = true;

        staticConfigOptions = {
          ## Logging ##
          log = {
            level = "INFO";
            filePath = "/var/log/traefik.log";
            format = "json";
            noColor = false;
            maxSize = 100;
            compress = true;
          };

          # metrics = {
          #   prometheus = {};
          # };

          # tracing = {};

          accessLog = {
            addInternals = true;
            filePath = "/var/log/traefik-access.log";
            bufferingSize = 100;
            fields = { names = { StartUTC = "drop"; }; };
            filters = { statusCodes = [ "204-299" "400-499" "500-599" ]; };
          };

          ## Dashboard ##
          api = { dashboard = true; };

          ## TLS Certificates ##
          certificatesResolvers = {
            tailscale.tailscale = { };
            letsencrypt = {

              ## DNS Challenge with Cloudflare ##
              acme = {
                email = "tyron.gabriel04@.dev";
                storage = "/var/lib/traefik/cert.json";
                dnsChallenge = { provider = "cloudflare"; };
              };
            };
          };

          ## Define Entrypoints ##
          entryPoints = {
            #redis = { address = "0.0.0.0:6381"; };
            #postgres = { address = "0.0.0.0:5433"; };

            ## Redirect http to https ##
            web = {
              address = "0.0.0.0:80";
              http.redirections.entryPoint = {
                to = "websecure";
                scheme = "https";
                permanent = true;
              };
            };

            websecure = {
              address = "0.0.0.0:443";
              http.tls = {
                certResolver = "letsencrypt";
                domains = [
                  {
                    main = "homelab.tyrongabriel.com";
                    sans = [ "*.homelab.tyrongabriel.com" ];
                  }
                  {
                    main = "tyrongabriel.com";
                    sans = [ "*.tyrongabriel.com" ];
                  }
                ];
              };
            };
          };
        };
      };
    };
  };
}
