{ lib, pkgs, ... }:
with lib;
with lib.tynix; {
  ## Disk Configuration ##
  imports = [ ./disks.nix ];

  ## Network name (Should match flake!) ##
  networking.hostName = "hp01";

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
      #adguardhome.enable = false;
    };
  };

  ## User Config ##
  user = {
    name = "tyron";
    authorizedKeys = [
      # change this to your ssh key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
    ];
    passwordlessSudo = true;
    trustedUser = true;
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

  system.stateVersion = "24.11";
}
