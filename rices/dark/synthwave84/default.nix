{
  delib,
  inputs,
  ...
}:
import "${inputs.main-config}/rices/synthwave84/default.nix" {
  inherit delib;
}
