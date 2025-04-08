# Tynix
Tyron's nixos dotfiles

# Usage

## Installing NixOS 🔧
<details>
  <summary>Install NixOS</summary>

Install NixOS on your target machine directly, or leverage Nixos-Anywhere for a remote installation. 🚀
Make sure you have passwordless sudo access via SSH on the target system before starting.

```bash
git clone git@github.com:tyrongabriel/tynix.git ~/tynix/
cd ~/tynix
nix develop # Enters dev shell

# Install NixOS and the flake on the target machine
# User must have passwordless sudo access
nixos-anywhere --flake '.#<system-name>' <user>@<host> --generate-hardware-config nixos-generate-config ./systems/<architecture>/<system>/hardware-configuration.nix
```

</details>

## Building 🛠️
Pull the repository and enter the development shell:

```bash
git clone git@github.com:tyrongabriel/tynix.git ~/tynix/
cd ~/tynix
nix develop
```

Then execute the following commands:

- To build the system configuration (using hostname to build the flake):

  ```bash
  nh os switch
  ```

- To build the user configuration (using hostname and username to build the flake):

  ```bash
  nh home switch
  ```

- To deploy to a remote server (e.g. Home Lab) via SSH (passwordless sudo recommended, not required):

  ```bash
  deploy .#<system-name> --hostname <hostname> --ssh-user <user> --skip-checks
  ```

- To generate the Home Lab diagram using nix-topology:

  ```bash
  nix build .#topology.config.output
  ```

## Secrets (Sops-Nix)



# Appendix
Heavily inspired by [hmajid2301's Nixicle config](https://github.com/hmajid2301/nixicle)
