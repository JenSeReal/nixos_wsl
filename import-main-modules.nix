# Import modules from main flake
# This file imports only the core modules needed for WSL
{
  inputs,
  lib,
  ...
}: let
  mainFlake = inputs.main-config.outPath;

  # Recursively find all .nix files in a directory, excluding subdirs named "modules" or "types"
  findNixFiles = dir:
    lib.concatMap (name: let
      path = dir + "/${name}";
      type = builtins.readFileType path;
    in
      if type == "directory"
      then
        # Skip subdirectories named "modules" or "types" (they contain submodule definitions)
        if name == "modules" || name == "types"
        then []
        else findNixFiles path
      else if type == "regular" && lib.hasSuffix ".nix" name
      then [path]
      else [])
    (builtins.attrNames (builtins.readDir dir));

  # Find .nix files but exclude package.nix files (they're not modules)
  findNixFilesExcludePackages = dir:
    lib.concatMap (name: let
      path = dir + "/${name}";
      type = builtins.readFileType path;
    in
      if type == "directory"
      then
        if name == "modules" || name == "types"
        then []
        else findNixFilesExcludePackages path
      else if type == "regular" && lib.hasSuffix ".nix" name && name != "package.nix"
      then [path]
      else [])
    (builtins.attrNames (builtins.readDir dir));

  # Import only specific directories we need for WSL
  imports =
    # Core config modules (programs, user, home, etc)
    (if builtins.pathExists "${mainFlake}/modules/config"
      then findNixFiles "${mainFlake}/modules/config"
      else [])
    # Programs modules
    ++ (if builtins.pathExists "${mainFlake}/modules/programs"
      then findNixFiles "${mainFlake}/modules/programs"
      else [])
    # Rices
    ++ (if builtins.pathExists "${mainFlake}/rices"
      then findNixFiles "${mainFlake}/rices"
      else [])
    # Packages (exclude package.nix files as they're not modules)
    ++ (if builtins.pathExists "${mainFlake}/packages"
      then findNixFilesExcludePackages "${mainFlake}/packages"
      else [])
    # Overlays
    ++ (if builtins.pathExists "${mainFlake}/overlays"
      then findNixFiles "${mainFlake}/overlays"
      else []);
in {
  # Import selected modules from main flake
  inherit imports;

  # Provide moduleSystem arg that denix modules expect
  config._module.args.moduleSystem = "nixos";
}
