{ config, ... }:
with config.lib.topology;
# let
#   inherit (config.lib.topology)
#     mkInternet
#     mkDevice
#     mkSwitch
#     mkRouter
#     mkConnection
#     ;
# in
{
  networks.home = {
    name = "Home";
    cidrv4 = "192.168.8.1/24";
  };

  # nodes = {
  #   #<host-name>.interfaces.<interface>.network = "home";

  #   # internet = mkInternet {
  #   #   connections = mkConnection "router" "wan1";
  #   # };
  #   #
  #   # router = mkRouter "linksys" {
  #   #   info = "Linksys0218";
  #   #   interfaceGroups = [
  #   #     ["eth1" "eth2"]
  #   #     ["wan1"]
  #   #   ];
  #   #   connections.eth1 = mkConnection "aurora" "enp0s31f6";
  #   #   connections.eth2 = mkConnection "equinox" "eno1";
  #   #
  #   #   interfaces.eth1.network = "home";
  #   #   interfaces.eth2.network = "home";
  #   # };
  # };
}
