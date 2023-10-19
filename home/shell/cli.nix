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
        Catppuccin-mocha = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
          };
          file = "Catppuccin-mocha.tmTheme";
        };
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
    p = "cd ~/repos && cd `${lib.getExe pkgs.skim} -p 'Open project?' --cmd '${lib.getExe pkgs.eza} --oneline --color=never'`";
  };
}
