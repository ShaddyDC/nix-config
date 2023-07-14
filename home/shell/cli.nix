{pkgs, ...}: let
  store-path = pkgs.writeScriptBin "store-path" ''
        nix --extra-experimental-features flakes eval -f "<nixpkgs>" --raw "''${1}"
      '';
in{
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

    vim.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };

    zellij = {
      enable = true;
      # bashIntegration = true;
    };

    btop.enable = true;
    htop.enable = true;
    exa.enable = true;

    skim = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'exa --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };

    bash.enable = true;
  };

  programs.bash.bashrcExtra = ''
    # run programs that are not in PATH with comma
    command_not_found_handler() {
      ${pkgs.comma}/bin/comma "$@"
    }
  '';

  home.shellAliases = {
    cdsk = "cd $(${pkgs.skim}/bin/sk)";
    p = "cd ~/repos && cd `${pkgs.skim}/bin/sk -p 'Open project?' -c ${pkgs.exa}/bin/exa`";
  };
}
