{options, config, ... }:
{
  #just turning on bluetooth
  hardware.bluetooth = {
    enable = if (config.bluetooth != "") true else false;
    powerOnBoot = true;
    settings = {
      General.Experimental = true;
    };
  };
}
