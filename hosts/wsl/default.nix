{
  delib,
  pkgs,
  ...
}:
delib.host {
  name = "wsl";

  rice = "synthwave84";
  # type = "laptop";

  nixos = {
    users.defaultUserShell = pkgs.nushell;
  };

  myconfig = {
    programs = {
      bat.enable = true;
      #     btop.enable = true;
      #     curl.enable = true;
      #     carapace.enable = true;
      #     codium.enable = true;
      #     direnv.enable = true;
      #     devenv.enable = true;
      #     git.enable = true;
      #     helix.enable = true;
      #     sudo.enable = true;
      #     fish.enable = true;
      #     neovim.enable = true;
      #     nh.enable = true;
      #     nix-ld.enable = true;
      #     nu.enable = true;
      #     starship.enable = true;
      #     zed.enable = true;
    };
  };
}
