{ lib, inputs, }:
let inherit (inputs) deploy-rs;
in {
  ## Create deployment configuration for use with deploy-rs.
  ## CREDIT TO hmajid2301's nixicle flake
  ##
  ## ```nix
  ## mkDeploy {
  ##   inherit self;
  ##   overrides = {
  ##     my-host.system.sudo = "doas -u";
  ##   };
  ## }
  ## ```
  ##
  #@ { self: Flake, overrides: Attrs ? {} } -> Attrs
  mkDeploy = { self, overrides ? { }, }:
    let
      hosts = self.nixosConfigurations or { };
      names = builtins.attrNames hosts;
      nodes = lib.foldl (result: name:
        let
          host = hosts.${name};
          userName = host.config.user.name or null;
          user = host.config.user or null;
          inherit (host.pkgs) system;
        in result // {
          ${name} = (overrides.${name} or { }) // {
            hostname = overrides.${name}.hostname or "${name}";
            profiles = (overrides.${name}.profiles or { }) // {
              system = (overrides.${name}.profiles.system or { }) // {
                path = deploy-rs.lib.${system}.activate.nixos host;
                remoteBuild = false;
                #host.config.tynix.selfBuildDeployment;
                #true; # Builds ALL systems on themselves! May need to parameterize that
              } // lib.optionalAttrs (userName != null) {
                # If a user is given -> use it an do sudo
                user =
                  "root"; # Because it is different than sshUser, will use sudo
                sshUser = userName;
              } // lib.optionalAttrs
                (host.config.security.tynix.doas.enable or false) {
                  sudo = "doas -u";
                } // lib.optionalAttrs (!user.passwordlessSudo) {
                  # If the user configured is not passwordless, ask for passwords
                  interactiveSudo = true;
                };
            };
          };
        }) { } names;
    in { inherit nodes; };
}
