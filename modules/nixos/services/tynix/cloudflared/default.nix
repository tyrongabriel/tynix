{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.services.tynix;
in {
  options.services.tynix = with types; {
    enable = mkEnableOption "Enable Cloudflared for tunnels and more";
    # Add more options here
    tunnelId = mkOption {
      type = types.string;
      default = "da5011c5-e8b2-405d-8f5e-094adbb80c29";
      description = "The ID of the tunnel to use";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      cloudflared = {
        package = pkgs.stable.cloudflared;

        enable = true;
        tunnels = {
          "${cfg.tunnelId}" = {
            credentialsFile = config.sops.secrets.cloudflared_ltc01.path;
            default = "http_status:404";

            ## Configure URL's ##
            ingress = {
              ## Wildcard rule for all other subdomains of tyrongabriel.com
              "*.tyrongabriel.com" = {
                service = "https://localhost";
                originRequest = {
                  #originServerName =  "*.tyrongabriel.com"; # Does not work as in https://homelamb.github.io/posts/using-cloudflare-tunnel-with-traefik/
                  noTLSVerify =
                    true; # Needed, otherwise Cloudflare will ask for a TLS cert for "localhost", which traefik will not provide!
                };
              };

              # "test.tyrongabriel.com" = {
              #   service =
              #     "https://localhost";
              #   originRequest = {
              #     originServerName =
              #       "test.tyrongabriel.com"; # Explicitly set for this specific host, lets cloudflare correctly fetch tls
              #   };
              # };
            };
          };
        };
      };
    };
  };
}
