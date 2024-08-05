{pkgs, ...}:
# media - control and enjoy audio/video
{
  imports = [
    ./rnnoise.nix
  ];

  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
    pulsemixer
    pulseaudio

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
    };

    feh.enable = true;

    obs-studio.enable = true;
  };

  services = {
    playerctld.enable = true;
  };
}
