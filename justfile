set shell := ["zsh", "-uc"]

default:
    just -l

# Updates files keys, used when new public key is added
sops-rekey:
    sops updatekeys ./**/secrets.yaml

install-nixos user host system port='22' architecture='x86_64-linux' :
    nixos-anywhere --flake .#{{system}} {{user}}@{{host}} --ssh-port {{port}} --generate-hardware-config nixos-generate-config ./systems/{{architecture}}/{{system}}/hardware-configuration.nix

generate-topology outPath='./images/topology/':
    nix build .#topology.config.output
    sudo cp result/* {{outPath}}
    rm -r ./result
