# Import packages from main flake
{
  inputs,
  lib,
  ...
}: let
  mainFlake = inputs.main-config.outPath;

  # Recursively find all .nix files in a directory, excluding subdirs named "modules" or "types"
  # and excluding constants.nix and package.nix files (package.nix files are not modules)
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
      else if type == "regular" && lib.hasSuffix ".nix" name && name != "package.nix" && name != "constants.nix"
      then [path]
      else [])
    (builtins.attrNames (builtins.readDir dir));
in {
  imports =
    if builtins.pathExists "${mainFlake}/packages"
    then findNixFilesExcludePackages "${mainFlake}/packages"
    else [];
}
