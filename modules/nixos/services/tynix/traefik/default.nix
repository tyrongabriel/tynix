{ config, lib, ... }:
with lib;
with lib.tynix;
let cfg = config.services.tynix.traefik;
in {
  options.services.tynix.traefik = with types; {
    enable = mkEnableOption "Enable traefik";
    dashboard = mkOpt (submodule {
      options = {
        enable = mkEnableOption
          "Enable graphical dashboard. (Should be secured with middleware!)";
        domain = mkOpt (nullOr str) null "Domain name for dashboard.";
      };
    }) { enable = false; } "Traefik dashboard config.";
    email = mkOpt (nullOr str) null "Email for dns.";
    cloudflare = mkOpt (submodule {
      options = {
        enable = mkEnableOption "Enable cloudflare dns challenge.";
        dnsApiTokenFile = mkOpt (nullOr path) null
          "API Key file for cloudflare. (Sops file with a line: CF_DNS_API_TOKEN=<token>)";
        apiEmailFile = mkOpt (nullOr path) null
          "API Email for cloudflare api access. (Sops file with a line: CF_API_EMAIL=<email>)";
      };
    }) { enable = false; } "Cloudflare configuration (DNS Challenge).";
    domains = mkOpt (listOf (submodule {
      options = {
        main = mkOpt str null "Main domain name.";
        sans = mkOpt (listOf str) [ ] "List of SANS domain names (Wildcards).";
      };
    })) [ ] "Domains to use for traefik.";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = ifThenElse cfg.cloudflare.enable
          (cfg.cloudflare.dnsApiTokenFile != null && cfg.cloudflare.apiEmailFile
            != null) true;
        message =
          "If cloudflare is enabled, both dnsApiTokenFile and apiEmailFile must be set.";
      }
      {
        assertion =
          ifThenElse cfg.dashboard.enable (cfg.dashboard.domain != null) true;
        message = "If dashboard is enabled, domain must be set.";
      }
      {
        assertion = cfg.email != null;
        message = "Email must be set.";
      }
    ];
    ## Open Ports ##
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    systemd.services.traefik = {
      environment = {
        # CF_API_EMAIL = config.sops.secrets.cloudflare_api_email.value;
        # CF_API_KEY = config.sops.secrets.cloudflare_api_key.value;
      };
      serviceConfig = {
        EnvironmentFile = ifThenElse cfg.cloudflare.enable [
          config.sops.secrets.cloudflare_api_email.path
          config.sops.secrets.cloudflare_dns_api_token.path
        ] [ ];
        User = "traefik";
      };
    };

    #sops.secrets.cloudflare_api_email = { sopsFile = ../../secrets.yaml; };
    #sops.secrets.cloudflare_dns_api_token = { sopsFile = ../../secrets.yaml; };

    services = {
      tailscale.permitCertUid = "traefik";

      traefik = {
        enable = true;
        group = "traefik";

        staticConfigOptions = {
          ## Logging ##
          log = {
            level = "TRACE";
            filePath = "${config.services.traefik.dataDir}/traefik.log";
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
            filePath = "${config.services.traefik.dataDir}/traefik-access.log";
            bufferingSize = 100;
            fields = { names = { StartUTC = "drop"; }; };
            filters = { statusCodes = [ "204-299" "400-499" "500-599" ]; };
          };

          ## Dashboard ##
          api = { dashboard = cfg.dashboard.enable; };
          # Access the Traefik dashboard on <Traefik IP>:8080 of your server
          #api.insecure = true;

          ## TLS Certificates ##
          certificatesResolvers = {
            tailscale.tailscale = { };
            dns-cloudflare = lib.mkIf cfg.cloudflare.enable {
              ## DNS Challenge with Cloudflare ##
              acme = {
                email = cfg.email;
                storage = "${config.services.traefik.dataDir}/acme.json";
                dnsChallenge = {
                  provider = "cloudflare";
                  propagation = {
                    disableChecks = true;
                    delayBeforeChecks = 60;
                  };
                  resolvers = [ "8.8.8.8:53" "1.1.1.1:53" ];
                };
              };
            };
            letsencrypt = {
              acme = {
                email = cfg.email;
                storage = "${config.services.traefik.dataDir}/acme.json";
                httpChallenge.entryPoint = "web";
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
                certResolver = ifThenElse cfg.cloudflare.enable "dns-cloudflare"
                  "letsencrypt";
                domains = cfg.domains;
                #[
                # {
                #   main = "home.tyrongabriel.com";
                #   sans = [ "*.home.tyrongabriel.com" ];
                # }
                # {
                #   main = "tyrongabriel.com";
                #   sans = [ "*.tyrongabriel.com" ];
                # }
                ## Mainly for testing -> Tailscale ##
                # {
                #   main = "ltc01.tail1c2108.ts.net";
                #   sans = [ "*.ltc01.tail1c2108.ts.net" ];
                # }
                #];
              };

            };
          };
        };

        ## Define endpoint for traefik dashboard ##
        dynamicConfigOptions = {
          http = {
            middlewares = {
              auth.basicAuth = {
                users = [
                  # Test : 1234
                  "test:$apr1$7QTyfrRD$Pk6ePBLx/YybzaoHvvdV90"
                ];
              };
              redirect-to-dashboard = lib.mkIf cfg.dashboard.enable {
                redirectRegex = {
                  # Regex matches only the exact root path "/"
                  regex = "^/$";
                  # Replacement is the target path
                  replacement = "/dashboard/";
                  # Use a permanent redirect (HTTP 308)
                  permanent = true;
                };
              };
              #sslheader.headers.customrequestheaders.X-Forwarded-Proto =
              #"https";
            };

            ## Configure routing ##
            routers = {
              traefik-dashboard = {
                entryPoints = [ "websecure" ]; # Configure entrypoints
                rule = "Host(`${cfg.dashboard.domain}`)";
                service = "api@internal"; # Service name
                tls.certResolver =
                  ifThenElse cfg.cloudflare.enable "dns-cloudflare"
                  "letsencrypt";
                middlewares =
                  [ "redirect-to-dashboard" ]; # SSO with Authentik TODO
              };
            };
          };
        };
      };
    };

    # Create log files with correct permissions
    systemd.tmpfiles.rules = [
      #"f /var/log/traefik.log - traefik traefik 0640" # file, path, user, group, mode
      #"f /var/log/traefik-access.log - traefik traefik 0640"
      #"d /var/lib/traefik - traefik traefik 0750" # Ensure directory exists for cert.json
    ];

    # (Optional) Log rotation
    # services.logrotate.settings.traefik = {
    #   directories = [ "/var/log/traefik.log" "/var/log/traefik-access.log" ];
    #   options = [ "missingok" "rotate 7" "daily" "copytruncate" "notifempty" ];
    #   postrotate = "systemctl reload systemd-journald.service";
    # };
  };
}
