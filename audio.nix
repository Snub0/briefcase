{options, config, ...}:
{
  #enables ALSA and checks to
  #enable or disable pulseaudio/pipewire
  hardware.pulseaudio = {
    enable = if (config.audio == "pulseaudio") then true else false;
  };
  services.pipewire = {
    enable = if (config.audio == "pipewire") then true else false;
    #alsa & pulse apps are now compatible
    alsa.enable = true;
    alsa.support32bit = true;
    pulse.enable = true;
  };
  #permission or something I dont really know what this is
  security.rtkit.enable = true;

  #bluetooth headsets
  environment.etc = if (config.bluetooth == "audio") then {
    "wireplumber/bluetooth.lua.d/51-bluez-config/lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  } else {};
}
