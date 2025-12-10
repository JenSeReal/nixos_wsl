# Import programs modules from main flake
{
  inputs,
  lib,
  ...
}: let
  mainFlake = inputs.main-config.outPath;

  # Recursively find all .nix files in a directory, excluding subdirs named "modules" or "types"
  # and excluding constants.nix files (to avoid conflicts with local constants)
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
      else if type == "regular" && lib.hasSuffix ".nix" name && name != "constants.nix"
      then [path]
      else [])
    (builtins.attrNames (builtins.readDir dir));
in {
  imports =
    if builtins.pathExists "${mainFlake}/modules/programs"
    then findNixFiles "${mainFlake}/modules/programs"
    else [];
}
