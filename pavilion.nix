{config, lib, ...}:
let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  hostname = "pavilion";
  username = "snub";
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 5d";
  };
  
  services.automatic-timezoned.enable = true;
  services.xserver.libinput.enable = true;

  networking = {
    inherit hostname;
    networkmanager.enable = true;
  };

  programs.zsh.enable = true;
  user.users.$(username) = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "lp" "scanner" ];
  };


}
