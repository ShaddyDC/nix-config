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

    extraConfig.gpg.format = "ssh";
  };

  programs.lazygit.enable = true;
  home.shellAliases = {
    lg = "lazygit";
  };
}
