# modules/programs/bat.nix
{
  inputs,
  pkgs,
  ...
} @ args:
# Import the module function from main-config and call it with our args
(import "${inputs.main-config.outPath}/modules/programs/bat.nix") args
