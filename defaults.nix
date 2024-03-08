{config, pkgs, lib, ... }:
{
  nix = lib.mkDefault {
    settings.experimentaal-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 5d";
    };
  };

  networking = {

  };  
}
