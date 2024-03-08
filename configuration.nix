{ config, pkgs, lib, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload"
  ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  ''; 
in
{
  imports = [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  boot.loader = { 
    systemd-boot = {
      enable = true;
      editor = false;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable networking
  networking = { 
    hostName = "nixos"; 
    networkmanager = {
      enable = true;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  services.xserver = {
    layout = "us";
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
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  services.xserver.libinput.enable = true;

  # Enables Qtile and GNOME with X11 
  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;
  };

  # Picom config
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
    fade = true;
    fadeDelta = 5;
    activeOpacity = 0.96;
    inactiveOpacity = 0.95;
  }; 	

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = false;
    package = pkgs.pulseaudioFull;
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs = {
    dconf.enable = true;
    zsh.enable = true;
  };
  users.users.snub = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Snub";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "lp" "scanner" ];
  };

  # Allow unfree packages
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    powerManagement = {
      enable = true;
    };
  }; 
 
  specialisation = {
    external-display.configuration = {
      system.nixos.tags = [ "external-display" ];
      hardware.nvidia = {
        prime.offload.enable = lib.mkForce false;
        powerManagement.enable = lib.mkForce false;
      };
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  environment.systemPackages = [
    nvidia-offload
    pkgs.slack-term
    pkgs.helix
    pkgs.feh
    pkgs.cudatoolkit
    pkgs.pavucontrol
    pkgs.ranger
    pkgs.pcmanfm
    pkgs.playerctl
    pkgs.rofi
    pkgs.vlc
    pkgs.alacritty
    pkgs.librewolf
    pkgs.zenith-nvidia
    pkgs.wget
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
    material-design-icons
  ];  

  system.stateVersion = "23.05"; 
  
  home-manager.users.snub = 
  { pkgs, ... }: 
  {
   home.stateVersion = "23.05";
   home.sessionVariables.GTK_THEME = "Nordic";

   systemd.user.targets.tray = {
     Unit = {
       Description = "Home Manager System Tray";
       Requires = [ "graphical-session-pre.target" ];
     };
   };

   services.blueman-applet.enable = true;

   services.flameshot = {
     enable = true;
     settings = {
       General = {
         uiColor = "#2e3440";
         contrastUiColor = "#4c566a";
       };
     };
   }; 

   home.pointerCursor = {
     name = "Nordzy-cursors";
     package = pkgs.nordzy-cursor-theme;
     gtk.enable = true;
     x11 = {
       enable = true;
       defaultCursor = true;
     };
   };

   services.udiskie = {
     enable = true;
   };

   programs.fzf = {
     enable = true;
     enableZshIntegration = true;
     colors = {
       bg = "#2e3440";
       fg = "#eceff4";
     };
   };

   services.polybar = {
     enable = true;
     script = "polybar bar &";
     package = pkgs.polybar.override {
       pulseSupport = true;
     };
     settings = {
       "bar/bar" = {
         bottom = true;
         width = "100%";
         height = "5.5%";
         fixed-center = true;
         foreground = "#d8dee9";
         background = "#00";
         border = {
           size = 8;
           color = "#00";
         };
         font = [ "Source Code Pro:size=13" "Material Design Icons:size=16" ];
         module.margin = {
           left = 1;
           right = 1;
         };
         modules = {
           left = "xworkspaces";
           right = "battery volume wlan clock powermenu";
         };
       };

       "module/powermenu" = {
         type = "custom/menu";
         expand-right = false;
         menu = [ [ {text = "%{B#bf616a}%{F#2e3440}    󰐥    "; exec = "shutdown -h now";} {text = "%{B#bf616a}%{F#2e3440}    󰑓    "; exec = "shutdown -h now --reboot";} ] ];

         label = {
           open = {
             text = "󰤁";
             padding = 4;
             foreground = "#2e3440";
             background = "#bf616a";
           };
           close = {
             text = "󰅚";
             padding = 4;
             foreground = "#2e3440";
             background = "#bf616a";
           };
         };

       };

       "module/wlan" = {
         type = "internal/network";
         interface = {
           text = "wlo1";
           type = "wireless";
         };

         interval = 3.0;

         format = {
           connected = "<ramp-signal><label-connected>";
           disconnected = "<label-disconnected>";
         };

         ramp-signal = {
           text = [ "󰤟" "󰤢" "󰤥" "󰤨" ];
           padding = 4;
           foreground = "2e3440";
           background = "#b48ead";
         };

         label = {
           connected = {
             text = "%essid%";
             padding = 4;
             foreground = "#b48ead";
             background = "#2e3440";
           };
           disconnected = "%{B#b48ead}%{F#2e3440}    󰤮    %{B- F-}%{B#2e3440}%{F#b48ead}    Off    ";
         };
       };

       "module/xworkspaces" = {
         type = "internal/xworkspaces";
         
         label = {
           active = {
             text = "󰜌";
             padding = 4;
             background = "#4c566a";
             foreground = "#81a1c1";
           };

           urgent = {
             text = "󰜌";
             background = "#2e3440";
             foreground = "#bf616a";
             padding = 4;
           };

           occupied = {
             text = "󰜌";
             background = "#2e3440";
             foreground = "#d8dee9";
             padding = 4;
           };

           empty = {
             text = "󰜌";
             background = "#2e3440";
             foreground = "#3b4252";
             padding = 4;
           };
         };
       };

       "module/volume" = {
         type = "internal/pulseaudio";

         click.right = "pavucontrol";

         interval = 2;

         format.volume = "<ramp-volume><label-volume>";

         ramp-volume = {
           text = [ "󰕿" "󰖀" "󰕾" ];
           background = "#81a1c1";
           foreground = "#2e3440";
           padding = 4;
         };

         label = {
           muted = "%{B#81a1c1}%{F#2e3440}    󰖁    %{B- F-}%{B#2e3440}%{F#81a1c1}    Mute    ";
           volume = {
             text = "%percentage%%";
             background = "#2e3440";
             foreground = "#81a1c1";
             padding = 4;
           };
         };
       };

       "module/clock" = {
         type = "internal/date";

         interval = 1.0;

         time = "%H:%M:%S";

         time-alt = "%m/%d/1%Y";

         label = {
           text = "%{B#d08770}%{F#2e3440}    󰅐    %{B- F-}%{B#2e3440}%{F#d08770}    %time%    ";
         };
       };

       "module/battery" = {
         type = "internal/battery";

         polling = 1;

         full-at = 99;

         battery = "BAT0";
         adapter = "ADP1";

         format = {
           charging = {
             text = "<label-charging>";
           };
           discharging = {
             text = "<ramp-capacity><label-discharging>";
           };
         };   

         label = {
           charging = { 
             text = "%{B#a3be8c}%{F#2e3440}    󰂄    %{B- F-}%{B#2e3440}%{F#a3eb8c}    %percentage%%    %{B-}";
           };
           discharging = { 
             text = "%percentage%%";
             padding = 4;
             foreground = "#ebcb8b";
             background = "#2e3440";
           };
           full = {
             text = "%{B#a3be8c}%{F#2e3440}    󰁹    %{B- F-}%{B#2e3440}%{F#a3be8c}    100%    %{B-}";
           };
           low = {
             text = "%{B#bf616a}%{F#2e3440}    󰂃    %{B- F-}%{B#2e3440}%{F#bf616a}   %percentage%%    %{B-}";
           };
         };

         ramp-capacity ={ 
           text = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰂂" ];
           padding = 4;
           foreground = "#2e3440";
           background = "#ebcb8b";
         };
       };
     };
   };

   programs.exa = {
     enable = true;
     enableAliases = true;
     icons = true;
   };

   programs.helix = {
     enable = true;
     languages = [
       {
         auto-format = true;
         name = "nix";
       }
     ];
     settings = {
       theme = "nord";
       editor = {
         line-number = "relative";
         lsp.display-messages = true;
       };
       keys.normal = {
         space.space = "file_picker";
         space.q = ":q";
         space.w = ":w";
       };
     };
   };

   qt = {
     enable = true;
     platformTheme = "gtk";
     style.name = "gtk2";
   };
   
   gtk = {
     enable = true;
     font = {
       name = "SauceCodePro Nerd Font Mono";
     };

     theme = {
       name = "Nordic";
       package = pkgs.nordic;
     };
     cursorTheme = {
       name = "Nordzy-cursors";
       package = pkgs.nordzy-cursor-theme;
     };
     iconTheme = {
       name = "Zafiro-icons-Dark";
       package = pkgs.zafiro-icons;
     };

     gtk3.extraConfig = {
       Settings = ''
         gtk-application-prefer-dark-theme=1
       '';
     };     

     gtk4.extraConfig = {
       Settings = ''
         gtk-application-prefer-dark-theme=1
       '';
     };     
   };
   
   programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    history.path = "$HOME/AAMB/.zsh_history"; 
    initExtra = 
    ''
      PROMPT='
      %F{green}  ❯%f %b'

      # >>> conda initialize >>>
      # !! Contents within this block are managed by ' init' !!
      __conda_setup="$('/home/snub/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
          eval "$__conda_setup"
      else
          if [ -f "/home/snub/anaconda3/etc/profile.d/conda.sh" ]; then
              . "/home/snub/anaconda3/etc/profile.d/conda.sh"
          else
              export PATH="/home/snub/anaconda3/bin:$PATH"
          fi
      fi
      unset __conda_setup
    '';
   };

   programs.alacritty = {
     enable = true;
     settings = {
       opacity = 0.9;
       window = {
         padding = {
           x = 20;
           y = 20;
         };
       };

       scrolling.multiplier = 3;

       cursor.style.shape = "Underline";

       font = {
         normal = {
           family = "SauceCodePro Nerd Font";
           style = "Regular";
         };
         bold = {
           family = "SauceCodePro Nerd Font";
           style = "Bold";
         };
         italic = {
           family = "SauceCodePro Nerd Font";
           style = "Italic";
         };
         bold_italic = {
           family = "SauceCodePro Nerd Font";
           style = "Bold Italic";
         };
         offset = {
           x = 0;
           y = 0;
         };
       };

       draw_bold_text_with_bright_colors = true;

       colors = {
         normal = {
          black = "#3b4252";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#88c0d0";
          white = "#e5e9f0";
         };

         bright = {
           black = "#4c566a";
           red = "#bf616a";
           green = "#a3be8c";
           yellow = "#ebcb8b";
           blue = "#81a1c1";
           magenta = "#b48ead";
           cyan = "#8fbcbb";
           white = "#eceff4";
         };

         dim = {
           black = "#373e4d";
           red = "#94545d";
           green = "#809575";
           yellow = "#b29e75";
           blue = "#68809a";
           magenta = "#8c738c";
           cyan = "#6d96a5";
           white = "#aeb3bb";
         };

         primary = {
           background = "#2e3440";
           foreground = "#d8dee9";
           dim_foreground = "#a5abb6";
         };

         cursor = {
           text = "#2e3440";
           cursor = "#d8dee9";
         };

         selection = {
           text = "CellForeground";
           background = "#4c566a";
         };
       };
     };
   };

   programs.vim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [ 
      lightline-vim
      nord-vim
      nerdtree
      vim-devicons
    ];
    extraConfig = 
    ''
      let NERDTreeShowHidden=2

      let g:lightline = {
             \ 'colorscheme': 'nord',
             \ 'active': {	
             \       'left': [ [ 'mode' ],
             \                 [ 'readonly', 'filename', 'modified' ] ],
             \       'right': [ [ 'filetype' ] ]
             \ },
   	 \}

      nnoremap q: <Nop>
      nnoremap <s-Q> :q<CR> 
      nnoremap <s-f> :NERDTree<CR>
      nnoremap <Tab> :tabn<CR>
      nnoremap <s-Tab> :tabp<CR>
      nnoremap <s-e> :tabe<CR>
      nnoremap w <C-w>
      nnoremap z :w<CR> 
     
      filetype on
      filetype plugin on 
      filetype indent on
    
      syntax on

      colorscheme nord
      set noshowmode
      set encoding=utf-8
      set ttymouse=sgr
      set showcmd
      set incsearch
      set nowrap
      set number
      set laststatus=2    
    '';    
   };

 }; 
}

