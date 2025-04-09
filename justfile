set shell := ["zsh", "-uc"]

default:
    just -l

# Updates files keys, used when new public key is added
sops-rekey:
    sops updatekeys ./**/secrets.yaml

install-nixos user host system port='22' architecture='x86_86-linux' :
    nix run github:nix-community/nixos-anywhere {{user}}@{{host}} -- --flake .#{{flake}} --generate-hardware-config nixos-generate-config ./systems/{{architecture}}/{{system}}/hardware-configuration.nix
