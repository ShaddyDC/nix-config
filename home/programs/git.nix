{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    delta = {
      enable = true;
    };

    extraConfig = {
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
    };

    aliases = {
      a = "add";
      b = "branch";
      c = "commit";
      ca = "commit --amend";
      cm = "commit -m";
      co = "checkout";
      d = "diff";
      ds = "diff --staged";
      p = "push";
      pf = "push --force-with-lease";
      pl = "pull";
      pr = "pull --rebase --autostash";
      l = "log";
      r = "rebase";
      s = "status --short";
      ss = "status";
      forgor = "commit --amend --no-edit";
      graph = "log --all --decorate --graph --oneline";
      oops = "checkout --";
    };

    userName = "ShaddyDC";
    userEmail = "shaddythefirst@gmail.com";
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
      signByDefault = true;
    };

    extraConfig = {
      gpg.format = "ssh";
      credential = {
        # Until SSH_ASKPASS is supported
        # https://github.com/martinvonz/jj/issues/469
        helper = "file";
      };
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git.overrideGpg = true;
    };
  };
  home.shellAliases = {
    lg = "lazygit";
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "ShaddyDC";
        email = "shaddythefirst@gmail.com";
      };
    };
  };
}
