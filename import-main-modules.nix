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
