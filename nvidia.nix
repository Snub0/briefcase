{pkgs, config, lib, ...}:
let
#gpu pci id: lspci | grep VGA  | grep -v $(lscpu | grep Model | awk '{print $3}') | awk '{print $NR}' | sed 's/\./:/g' 
#cpu pci id: lspci | grep VGA  | grep $(lscpu | grep Model | awk '{print $3}') | awk '{print $NR}' | sed 's/\./:/g'
in
{
  #loads drivers for x and wayland
  services.xserver.videoDrivers = if (config.gpu == "nvidia") ["nvidia"] else [];
  
  hardware.nvidia = {
    prime = if (config.laptop == true) then {
      intelBusId = ;

    };
    modesettings.enable = true;

    #experimental maybe buggy
    powerManagement = {
      enable = true;

      #only works for Turing+
      finegrained = config.gpu.finegrained;
    };
    
    #opensource kernel module(not nouveau) currently alpha
    open = false;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.${config.gpu.driver};
  };
}
