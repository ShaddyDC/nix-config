{pkgs, default, ...}: {
  home.packages = with pkgs; [gtklock];

  # TODO: https://github.com/jovanlanik/gtklock/wiki/Per-output-background-example
  xdg.configFile."gtklock/style.css".text = ''
    window {
      background-image: url("${default.wallpaper}");
      font-family: Product Sans;
    }

    grid > label {
      color: transparent;
      margin: -20rem;
    }

    button {
      all: unset;
      color: transparent;
      margin: -20rem;
    }

    #clock-label {
      font-size: 6rem;
      margin-bottom: 4rem;
      text-shadow: 0px 2px 10px rgba(0,0,0,.1);
    }

    entry {
      border-radius: 16px;
      margin: 6rem;
      box-shadow: 0 1px 3px rgba(0,0,0,.1);
    }
  '';
}
