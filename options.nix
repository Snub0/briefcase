{lib, ...}:
{
  options = {
    #specify audio server of pipewire or pulseaudio
    audio = lib.mkOption {
      type = lib.types.str;
      default = "none";
    #specify if bluetooth is either for: audio, other(purely file-sharing idk), or none
    bluetooth = lib.mkOption {
      type = lib.types.str;
      default = "none";
    };
    gpu = lib.mkOption {
      type = lib.types.attrs;
      default = {
        #nvidia, amd, or none
        brand = "none";
       
        #nvidia specific options
        finegrained = false;
        driver = "vulkan_beta";
      };
    };
    
    laptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

  };

}
