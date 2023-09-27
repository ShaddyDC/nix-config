{
  pkgs,
  lib,
  ...
}: let
  store-path = pkgs.writeScriptBin "store-path" ''
    nix --extra-experimental-features flakes eval -f "<nixpkgs>" --raw "''${1}"
  '';
in {
  home.packages = with pkgs; [
    # archives
    zip
    unzip
    unrar

    # utils
    file
    du-dust
    duf
    fd
    ripgrep
    wget
    curl
    python311
    socat
    jc

    # file managers
    joshuto
    ranger

    # nix
    comma
    store-path
  ];

  programs = {
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "Catppuccin-mocha";
      };
      themes = {
        Catppuccin-mocha = builtins.readFile (pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme";
          hash = "sha256-qMQNJGZImmjrqzy7IiEkY5IhvPAMZpq0W6skLLsng/w=";
        });
      };
    };

    yazi = {
      enable = true;
      enableBashIntegration = true;
    };

    vim.enable = true;
    neovim = {
      enable = true;
      # defaultEditor = true;
    };

    zellij = {
      enable = true;
      # bashIntegration = true;
    };

    btop.enable = true;
    htop.enable = true;
    eza = {
      enable = true;
      enableAliases = true;
    };

    skim = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview '${lib.getExe pkgs.eza} --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };

    bash.enable = true;
  };

  programs.bash.bashrcExtra = ''
    # run programs that are not in PATH with comma
    command_not_found_handler() {
      ${lib.getExe pkgs.comma} "$@"
    }
  '';

  services.pueue = {
    enable = true;
    settings = {
      shared = {};
      client = {};
      daemon = {};
    };
  };

  home.shellAliases = {
    cdsk = "cd $(SKIM_DEFAULT_COMMAND='${lib.getExe pkgs.fd} --type d' ${lib.getExe pkgs.skim})";
    p = "cd ~/repos && cd `${lib.getExe pkgs.skim} -p 'Open project?' -c ${lib.getExe pkgs.eza}`";
  };
}
