{
  description = "system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  };
  
  outputs = 
  { nixpkgs, home-manager, ... }: 
  let
    system = "x86_64-linux";
    username = "snub"
    timezone = "America/Los_Angeles";

    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    nixosConfigurations = {
      config.nixos = lib.nixosSystem {
        system = "x86_64-linux";

        #--NIX--#
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-then 5d";
        };

        #--NETWORKING--#
        networking = {
          hostname = mkDefault 
          networkmanager.enable = true;
        };
        
        #--LOCALE--#
        time.timeZone = "America/Los_Angeles";
        services.xserver = {
          layout = mkDefault "us";
          libinput.enable = true;
          xkbVariant = "";
        };
        i18n = {
          defaultLocale = "en_US.UTF-8";
          extraLocaleSettings = {
            LC_ADDRESS = "en_US.UTF-8";
            LC_IDENTIFICATION = "en_US.UTF-8";
            LC_MEASUREMENT = "en_US.UTF-8";
            LC_MONETARY = "en_US.UTF-8";
            LC_NAME = "en_US.UTF-8";
            LC_NUMBERIC = "en_US.UTF-8";
            LC_PAPER = "en_US.UTF-8";
            LC_TELEPHONE = "en_US.UTF-8";
            LC_TIME = "en_US.UTF-8";
          };
        };
        
        #--USER--#
        programs.zsh.enable = true;
        user.users.$(username) = {
          shell = pkgs.zsh;
          isNormalUser = true;
          extraGroups = [ "networkmanager" "audio" "video" "lp" "scanner" ];
        };




        modules = [ ./configuration.nix ]  ;
      }
    }; 
  };
}
