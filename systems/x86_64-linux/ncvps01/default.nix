{ lib, pkgs, ... }:
with lib;
with lib.tynix; {
  ## Disk Configuration ##
  imports = [ ./disks.nix ./hardware-configuration.nix ];

  ## Networking ##
  networking = {
    ## Network name (Should match flake!) ##
    hostName = "ncvps01";
    useDHCP = false; # VPS requires manual conf
    nameservers = [
      "8.8.8.8" # Google's public DNS
      "8.8.4.4" # Google's public DNS
      "1.1.1.1" # Cloudflare's public DNS
      "9.9.9.9" # Quad9 DNS
    ];
  };

  # Define the static network configuration for the 'ens3' interface
  networking.interfaces.ens3 = {
    # Set this to false to ensure no DHCP is used for this interface
    useDHCP = false;
    # Configure the IPv4 address and subnet mask
    ipv4.addresses = [{
      address = "152.53.149.109";
      prefixLength = 22;
    }];
  };

  # Set the default gateway
  networking.defaultGateway = "152.53.148.1";

  ## Suites this machine is part of ##
  suites = { common.enable = true; };

  ## Services to run ##
  services = {
    # SSH Also enabled in homelab config. Root login not though!
    ssh = {
      enable = true;
      rootLogin = "no";
    };

    tynix = {
      enable = true;
      #traefik.enable = true;
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
    passwordlessSudo = false;
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
  #environment.systemPackages = with pkgs; [  ];

  system.stateVersion = "25.05";
}
