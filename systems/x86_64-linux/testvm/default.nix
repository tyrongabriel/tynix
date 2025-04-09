{ modulesPath, lib, pkgs, ... }: {
  # VM: If using the alpine vm: update-extlinux (Script to update the extlinux bootloader), vi to /boot/extlinux.cfg and add kexec_load_disabled=0 to append
  # Installation:
  # nix run github:nix-community/nixos-anywhere name@ip -- --flake .#testvm --generate-hardware-config nixos-generate-config ./systems/x86_64-linux/testvm/hardware-configuration.nix
  # deploy updates:
  # deploy .#testvm --hostname 192.168.122.68  --ssh-user tyron --skip-checks --interactive-sudo true
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disks.nix
  ];

  config = {
    suites.server.enable = true;

    user = {
      name = "tyron";
      # authorizedKeys = [
      #   # change this to your ssh key
      #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
      # ];
      passwordlessSudo = true;
      trustedUser = true;
    };

    suites.homelab.enable = true;

    services.ssh = {
      authorizedKeys = [
        # change this to your ssh key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
      ];
    };

    boot.loader.grub = {
      # no need to set devices, disko will add all devices that have a EF02 partition to the list already
      # devices = [ ];
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    networking.hostName = "testvm";

    environment.systemPackages =
      map lib.lowPrio (with pkgs; [ curl gitMinimal iputils ]);

    cli.programs.nh.enable = true;
    locale.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [
      # change this to your ssh key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
    ];

    system.stateVersion = "24.11";
  };

}
