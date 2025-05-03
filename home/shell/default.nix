{config, ...}: let
  d = config.xdg.dataHome;
  c = config.xdg.configHome;
  cache = config.xdg.cacheHome;
in {
  imports = [
    ./cli.nix
    ./helix.nix
    ./nushell
    ./nix.nix
    ./starship.nix
  ];

  # add environment variables
  home.sessionVariables = {
    # TODO Update variables
    # The two machines probably have a different value for the environment variable LESS. I recommend using it and leaving PAGER=less as is. (As I recently learned, it is also possible to customize these via LESSKEY, but that's rare and more confusing to use. I learned about it because Nixpkgs seems to use that, it could be another reason two configs behave differently).
    # So, e.g. export PAGER=less; export LESS=FRX.
    # I use LESS="FRX --mouse --wheel-lines=2 M" myself to scroll with the mouse wheel and have a nicer status bar. I'm not sure it's worth it, LESS=FRX is easier to remember.
    LESSHISTFILE = cache + "/less/history";
    LESSKEY = c + "/less/lesskey";
    WINEPREFIX = d + "/wine";
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    # enable scrolling in git diff
    DELTA_PAGER = "less -R";

    EDITOR = "hx";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };
}
