set shell := ["zsh", "-uc"]

default:
    just -l

# Updates files keys, used when new public key is added
sops-rekey:
    sops updatekeys ./**/secrets.yaml
