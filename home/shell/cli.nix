{
  pkgs,
  lib,
  ...
}: let
  store-path = pkgs.writeScriptBin "store-path" ''
    nix --extra-experimental-features flakes eval -f "<nixpkgs>" --raw "''${1}"
  '';
in {
  home.packages = with pkgs; let
    pyWithPackages = python3.withPackages (py: [
      py.llm
      py.llm-anthropic
    ]);
    llm = runCommand "llm" {} ''
      mkdir -p $out/bin
      ln -s ${pyWithPackages}/bin/llm $out/bin/llm
    '';
  in [
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
    hexyl
    viu
    ouch
    mdcat
    httpie
    trashy
    procs
    doggo
    curlie
    lazyjj
    llm
    aider-chat
    cntr
    claude-code

    # file managers
    joshuto
    ranger
    kondo
    broot

    # nix
    comma
    store-path

    zed-editor
    code-cursor
  ];

  programs = {
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };

    yazi = {
      enable = true;
      enableBashIntegration = true;
    };

    zoxide.enable = true;
    broot.enable = true;

    bottom.enable = true;

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
      enableNushellIntegration = false;
      # enableAliases = true;
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

  home.sessionVariables = {
    PAGER = "less -FR";
  };

  # home.shellAliases = {
  #   cdsk = "cd $(SKIM_DEFAULT_COMMAND='${lib.getExe pkgs.fd} --type d' ${lib.getExe pkgs.skim})";
  #   p = "cd ~/repos; cd `${lib.getExe pkgs.skim} -p 'Open project?' --cmd '${lib.getExe pkgs.eza} --oneline --color=never'`";
  # };
}
