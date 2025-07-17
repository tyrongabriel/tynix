{ lib, pkgs, config, ... }:
with lib;
with lib.tynix; {
  ## Disk Configuration ##
  imports = [ ./disks.nix ./hardware-configuration.nix ];

  ## Networking ##
  networking = {
    ## Network name (Should match flake!) ##
    hostName = "ltc01";

    ## WOL - Wake on Lan
    interfaces.enp0s31f6.wakeOnLan = {
      enable = true;
      policy = [ "magic" ];
    };
  };

  ## Need to run:
  # cloudflare login (Creates cert.pem to auth)
  # cloudflare tunnel create <name> (Creates credentials file we need to save with sops!)
  # Copy the <uuid>.json file and enter (With '') into sops
  ##
  ## Cloudflare tunnel ##
  sops.secrets.cloudflared_ltc01 = {
    sopsFile = ../../../modules/nixos/services/secrets.yaml;
    #owner = "cloudflared";
  };
  services = {
    cloudflared = {
      package = pkgs.stable.cloudflared;

      enable = true;
      tunnels = {
        "da5011c5-e8b2-405d-8f5e-094adbb80c29" = {
          credentialsFile = config.sops.secrets.cloudflared_ltc01.path;
          default = "http_status:404";

          ## Configure URL's ##
          ## Configure URL's ##
          ingress = {
            # Existing specific rule for test.tyrongabriel.com (optional, can be covered by wildcard)
            "test.tyrongabriel.com" = {
              service =
                "https://localhost"; # Assuming Traefik listens on localhost:443 for HTTPS
              originRequest = {
                originServerName =
                  "test.tyrongabriel.com"; # Explicitly set for this specific host
              };
            };

            ## Wildcard rule for all other subdomains of tyrongabriel.com
            "*.tyrongabriel.com" = {
              service =
                "https://localhost"; # Cloudflare will pass the original Host header
              originRequest = {
                # Cloudflare automatically preserves the Host header for wildcard origins.
                # No need for explicit originServerName here if you want it to match the incoming hostname.
                # If you *do* need a specific originServerName for *all* wildcards, you'd set it here,
                # but that defeats the purpose of dynamically matching.
                # For dynamic matching, simply omit or comment out originServerName,
                # as the Host header is passed by default.
              };
            };

            # Catch-all for any other requests not matching the above
            "*" = { service = "http_status:404"; };
          };
        };
      };
    };
  };

  ## Suites this machine is part of ##
  suites = {
    server.enable = true;
    homelab.enable = true;
  };

  ## Services to run ##
  services = {
    # SSH Also enabled in homelab config. Root login not though!
    ssh = {
      enable = true;
      rootLogin = "no";
    };

    tynix = {
      enable = true;
      traefik.enable = true;
      adguardhome.enable = true;
    };

    ## Endpoint to access router config ##
    traefik.dynamicConfigOptions.http = {
      ## Configure traefik service ##
      services = {
        ## Enter all servers for load balancing ##
        gli-router.loadBalancer.servers = [{ url = "http://192.168.8.1"; }];
      };

      ## Configure routing ##
      routers = {
        gli-router = {
          entryPoints = [ "websecure" ]; # Configure entrypoints
          rule =
            "Host(`router.home.tyrongabriel.com`)"; # Rule for which domain to route to router
          service = "gli-router"; # Service name
          tls.certResolver = "letsencrypt";
          #middlewares = [ "authentik" ]; # SSO with Authentik
        };
      };
    };
  };

  ## User Config ##
  user = {
    name = "tyron";
    authorizedKeys = [
      # change this to your ssh key
      # Yoga
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
      # Legion
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsaPaXFmUqflCno/K8Y1RNYDvn1sRZwmhxNaBCtKun8yiQkxwFlcld82kUPKMxxCzjWSBYSQ9YFJYGpr+xZtRjdLtesgKf3ngOtBLsOxDRswhlcLboyFd/JCSSKVVaBxRswtfYvs0wH4g3P+ZEEWP9xMNaY8f2sqoMdpSDwbEN0Dk8n6aQKfBVbOjrfHIzuL9dQlr4akdf+tJsGUmg/5oPuPAwCCMvYG6y4iPFJ92Vo+dM/3EYVW4jaE5MnLRttlY+KxR+Kw81RIpkM3FERd0XihXg2DxJ+sbLPsF9sFX+rcab6xB4VnHbtO0liuEDe2GLiz8P2HLL7EF9ces3hCN5BVeZWJAoWA/Y38TzahK7IT/So4x1L7doTwH8x7TSYrANc7AShF9MaQnKU1fyXH0v9qBn3L74kRqLPqMzmzSFQ5ogC5JEBZBZ+/aICwUOlRknwJDmyrcPLGgFPOIp/Yfa59E1aU6OejvbuNCDcy8fH3qceXY8fffpl4ZSNegNrws= tyron@Ty-Laptop"
    ];
    passwordlessSudo = true;
    trustedUser = true;
    shell = pkgs.zsh;
  };

  ## Boot Config ##
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems =
      mkForce [ "btrfs" ]; # Force support for my used filesystem

    ## Bootloader ##
    # TODO: Fit into a module!
    loader.grub = {
      # no need to set devices, disko will add all devices that have a EF02 partition to the list already
      # devices = [ ];
      # device = "nodev"; # No specific partition
      # useOSProber = true; # Autodetect windows
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  ## Extra packages ##
  environment.systemPackages = with pkgs; [ stable.cloudflared ];

  system.stateVersion = "24.11";
}
