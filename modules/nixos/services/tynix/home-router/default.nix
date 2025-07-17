{ lib, config, ... }:
with lib;
with lib.tynix;
let cfg = config.services.tynix.home-router;
in {
  options.services.tynix.home-router = with types; {
    enable = mkEnableOption "Enable Traefik routing to home-router";
    url = mkOption {
      type = types.str;
      default = "http://192.168.8.1";
      description = "URL of the home router";
    };
    # Add more options here
  };

  config = lib.mkIf cfg.enable {
    ## Endpoint to access router config ##
    traefik.dynamicConfigOptions.http = {
      ## Configure traefik service ##
      services = {
        ## Enter all servers for load balancing ##
        gli-router.loadBalancer.servers = [{ url = cfg.url; }];
      };

      ## Configure routing ##
      routers = {
        gli-router = {
          entryPoints = [ "websecure" ]; # Configure entrypoints
          rule =
            "Host(`router.home.tyrongabriel.com`)"; # Rule for which domain to route to router
          service = "gli-router"; # Service name
          tls.certResolver = "dns-cloudflare";
          #middlewares = [ "authentik" ]; # SSO with Authentik
        };
      };
    };
  };
}
