{
  description = "WSL NixOS configuration extending main Denix setup";

  inputs = {
    main-config.url = "github:jensereal/nixos";
    nixpkgs.follows = "main-config/nixpkgs";
    denix.follows = "main-config/denix";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = {
    denix,
    main-config,
    nixos-wsl,
    ...
  } @ inputs:
    denix.lib.configurations {
      moduleSystem = "nixos";
      homeManagerUser = "jfp";

      # Scan local hosts and modules
      paths = [
        ./hosts
        ./modules
        ./overlays
        ./packages
        ./rices
      ];

      # Add WSL module
      extraModules = [nixos-wsl.nixosModules.default];

      # Use extensions from main flake
      extensions = import "${main-config}/extensions" {delib = denix.lib;};

      # Merge all inputs so modules can access them
      specialArgs = {
        inputs =
          main-config.inputs
          // inputs
          // {
            inherit nixos-wsl;
          };
      };
    };
}
