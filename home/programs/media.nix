{pkgs, ...}:
# media - control and enjoy audio/video
# input denoising lives in modules/workstation.nix (pipewire + deepfilternet)
{
  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
    pulsemixer
    pulseaudio

    # music
    pear-desktop

    # images
    imv
    feh

    # videos
    vlc

    # download
    yt-dlp

    # util
    ffmpeg
  ];

  programs = {
    mpv = {
      enable = true;
      defaultProfiles = ["gpu-hq"];
      scripts = [pkgs.mpvScripts.mpris];
      config.save-position-on-quit = true;
    };

    feh.enable = true;

    obs-studio.enable = true;
  };

  services = {
    playerctld.enable = true;
  };
}
