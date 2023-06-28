{pkgs, ...}: {
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
    helix = {
      enable = true;
      settings = {
        theme = "catppuccin_mocha";

        editor = {
          color-modes = true;
          cursorline = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          indent-guides = {
            render = true;
            rainbow-option = "dim";
          };
          lsp.display-inlay-hints = true;
          # rainbow-brackets = true;
          statusline.center = ["position-percentage"];
          true-color = true;
          whitespace.characters = {
            newline = "↴";
            tab = "⇥";
          };
        };
        keys.normal.space.u = {
          f = ":format"; # format using LSP formatter
          w = ":set whitespace.render all";
          W = ":set whitespace.render none";
        };
      };
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
}
