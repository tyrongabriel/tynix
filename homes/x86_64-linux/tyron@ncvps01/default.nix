{ ... }: {
  user = {
    enable = true;
    name = "tyron";
  };

  suites = {
    server.enable = true;
    development.enable = true;
  };

  home.stateVersion = "24.11";
}
