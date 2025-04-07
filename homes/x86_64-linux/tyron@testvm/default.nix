{ pkgs, ... }:
{
  home.packages = with pkgs; [
    btop
    devbox
    fzf
  ];

  user = {
    enable = true;
    name = "tyron";
  };

  home.stateVersion = "24.11";
}
