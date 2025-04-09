{ lib, config, pkgs, ... }:
with lib;
with lib.tynix;
let cfg = config.cli.shells.zsh;
in {
  options.cli.shells.zsh = with types; {
    enable = mkEnableOption "Enable zsh shell";
    # Add more options here
  };

  config = mkIf cfg.enable {
    ## ZSH Config ##
    programs.zsh = {
      enable = mkDefault true;
      enableCompletion = mkDefault true;
      autosuggestion.enable = mkDefault true;

      ## Shell Init ##
      initExtra = ''
        unalias gcd 2>/dev/null
      '';

      ## Configure Aliases ##
      shellAliases = {
        ll = "ls -la";
        lah = "ls -lah";
      };
      syntaxHighlighting.enable = mkDefault true;

      ## Oh my zsh styling ##
      oh-my-zsh = {
        enable = mkDefault true;
        theme = "lambda";
        plugins = [
          "git" # Git Aliases
          "cp" # Progress bar cp
        ];
      };

      ## ZSH Plugins ##
      plugins = [{
        ## Plugin to get zsh in nix-shells ##
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }];

    };
  };
}
