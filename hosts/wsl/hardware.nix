{
  delib,
  inputs,
  ...
}: let
  stateVersion = "25.05";
in
  delib.host rec {
    name = "wsl";
    system = "x86_64-linux";
    home.home.stateVersion = stateVersion;
    nixos = {
      imports = [
        inputs.nixos-wsl.nixosModules.wsl
      ];

      nixpkgs.hostPlatform = system;
      system.stateVersion = stateVersion;

      wsl = {
        enable = true;
        defaultUser = "jfp";
        startMenuLaunchers = true;

        wslConf = {
          automount = {
            root = "/mnt";
          };
        };
      };
    };
  }
