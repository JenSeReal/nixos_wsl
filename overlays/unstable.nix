{
  delib,
  inputs,
  ...
}:
import "${inputs.main-config}/overlays/unstable.nix" {
  inherit delib inputs;
}
