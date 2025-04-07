{
  inputs,
  ...
}:
## Way to get nixpkgs stable inside of other modules ##
## Courtesy of: https://github.com/snowfallorg/lib/issues/171#issuecomment-2727484052 ##
## Example https://gitlab.com/pinage404/dotfiles/-/blob/main/systems/service/ollama.nix?ref_type=heads#L8 ##
final: prev: {
  stable = import inputs.nixpkgs-stable {
    inherit (prev) system;
    config = {
      allowUnfree = true;
    };
  };
}

## Explaination ##
# Overlays take in packages, and return a new set of packages
# This overlay, essentially returns a packages, which has a .stable including all the stable packages
