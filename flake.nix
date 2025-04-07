{
  inputs = {
    ## Nixpkgs Channels ##
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    ## Home-Manager ##
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Structuring of NixOS/HomeManager modules ##
    ## Doc: https://snowfall.org/reference/lib/ ##
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Automated partitioning of disks ##
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Styling ##
    catppuccin.url = "github:catppuccin/nix";
    stylix.url = "github:danth/stylix";

    ## Homelab ##

    # Self-Hostable binaries cache
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Network topology generator
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Remote deployment of configs
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Remote Installation of nixos ##
    nixos-anywhere = {
      url = "github:numtide/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };

    ## Set of hardware configurations for NixOS ##
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };

    ## Secrets management with SOPS ##
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## ISO Generators for NixOS ##
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Utility to use uninstalled binaries by prefixing command with , ##
    comma = {
      url = "github:nix-community/comma";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;

        snowfall = {
          metadata = "tynix";
          namespace = "tynix";
          meta = {
            name = "tinyx";
            title = "Tyron's Nix Flake";
          };
        };
      };
    in
    lib.mkFlake {
      # Configure channel: https://snowfall.org/guides/lib/channels/
      channels-config = {
        allowUnfree = true;
        # Allow certain insecure packages
        # permittedInsecurePackages = [
        # ];

        # Additional configuration for specific packages.
        # config = {
        #   # For example, enable smartcard support in Firefox.
        #   firefox.smartcardSupport = true;
        # };
      };

      ## Modules to add to all NixOS systems ##
      systems.modules.nixos = with inputs; [
        #stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        nix-topology.nixosModules.default
      ];

      ## Configure a specific host's modules ##
      # systems.hosts.<host-name>.modules = with inputs; [
      #   nixos-hardware.nixosModules.<the-modules>
      # ];

      ## Add modules to all homes ##
      # homes.modules = with inputs; [
      #   impermanence.nixosModules.home-manager.impermanence
      # ];

      ## Add overlays ##
      overlays = with inputs; [
        nix-topology.overlays.default
      ];

      ## Deployrs using lib by https://github.com/hmajid2301/nixicle ##
      deploy = lib.mkDeploy { inherit (inputs) self; };

      ## Run deployment checks ##
      checks = builtins.mapAttrs (
        system: deploy-lib: deploy-lib.deployChecks inputs.self.deploy
      ) inputs.deploy-rs.lib;

      ## Nix topology ##
      topology =
        with inputs;
        let
          host = self.nixosConfigurations.${builtins.head (builtins.attrNames self.nixosConfigurations)};
        in
        import nix-topology {
          inherit (host)
            pkgs
            ; # Only this package set must include nix-topology.overlays.default
          modules = [
            (import ./topology { inherit (host) config; })
            { inherit (self) nixosConfigurations; }
          ];
        };
    };
}
