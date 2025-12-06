{
  description = "Private configuration extending the main Denix setup";

  inputs = {
    # Reference your main flake repository
    main-config = {
      url = "github:jensereal/nixos";
    };

    # Follow inputs from main config to maintain consistency
    nixpkgs.follows = "main-config/nixpkgs";
    nixpkgs-unstable.follows = "main-config/nixpkgs-unstable";
    home-manager.follows = "main-config/home-manager";
    denix.follows = "main-config/denix";

    # Optionally follow other inputs you need
    nur.follows = "main-config/nur";
    stylix.follows = "main-config/stylix";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = {
    denix,
    nixpkgs,
    main-config,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;

    # Scan for private package files
    packageNixFiles = lib.pipe ./packages [
      builtins.readDir
      (lib.filterAttrs (
        name: type:
          type
          == "directory"
          && builtins.pathExists (./packages + "/${name}/package.nix")
      ))
      (lib.mapAttrsToList (name: _: ./packages + "/${name}/package.nix"))
    ];

    # Find module subdirectories
    moduleSubdirs = let
      findModuleDirs = dir:
        lib.concatMap (
          name: let
            path = dir + "/${name}";
            type = builtins.readFileType path;
          in
            if type == "directory"
            then
              (
                if name == "modules" || name == "types"
                then [path]
                else []
              )
              ++ findModuleDirs path
            else []
        ) (builtins.attrNames (builtins.readDir dir));
    in
      if builtins.pathExists ./modules
      then findModuleDirs ./modules
      else [];

    # Create configurations using Denix
    mkConfigurations = moduleSystem:
      denix.lib.configurations {
        inherit moduleSystem;
        homeManagerUser = "jfp"; # Keep the same user as main config

        # Paths to scan for configurations
        paths = [
          ./hosts
          ./rices
          ./modules
          ./overlays
          # ./packages # Private packages
        ];

        # Exclude package.nix files and module subdirectories from auto-import
        exclude = packageNixFiles ++ moduleSubdirs;

        # Extensions - you can add custom extensions or use the ones from main
        extensions = import ./extensions {delib = denix.lib;};

        # Special arguments passed to all modules
        specialArgs = {
          inherit inputs moduleSystem;
          # Make main config available to all modules
          mainConfig = main-config;
        };
      };
  in {
    # Your private configurations
    nixosConfigurations = mkConfigurations "nixos";
    homeConfigurations = mkConfigurations "home";
  };
}
