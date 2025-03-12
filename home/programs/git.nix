{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [gh glab watchman];

  programs.git = {
    enable = true;
    package = pkgs.gitFull;

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
        helper = "libsecret";
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
      core.fsmonitor = "watchman";
      core.watchman.register_snapshot_trigger = true;
      user = {
        name = "ShaddyDC";
        email = "shaddythefirst@gmail.com";

      # Some inspiration by https://gist.github.com/thoughtpolice/8f2fd36ae17cd11b8e7bd93a70e31ad6

      git = {
        auto-local-bookmark = false;
        private-commits = "blacklist()";
        colocate = true;
        sign-on-push = true;
      };

      aliases = {
        tug = ["bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-"];

        # Convenient shorthands.
        d = ["diff"];
        s = ["show"];
        ll = ["log" "-T" "builtin_log_detailed"];
        xl = ["log" "-r" "all()"];

        # Get all open stacks of work.
        open = ["log" "-r" "open()"];

        # Retrunk a series. Typically used as `jj retrunk -s ...`, and notably can be
        # used with open:
        # - jj retrunk -s 'all:roots(open())'
        retrunk = ["rebase" "-d" "trunk()"];
      };

      revset-aliases = {
        "user(x)" = "author(x) | committer(x)";

        # Private and WIP commits that should never be pushed anywhere. Often part of
        # work-in-progress merge stacks.
        "tmp()" = "description(glob:\"wip:*\")";
        "wip()" = "description(glob:\"wip:*\")";
        "private()" = "description(glob:\"private:*\")";
        "blacklist()" = "wip() | tmp() | private()";

        # stack(x, n) is the set of mutable commits reachable from 'x', with 'n'
        # parents. 'n' is often useful to customize the display and return set for
        # certain operations. 'x' can be used to target the set of 'roots' to traverse,
        # e.g. @ is the current stack.
        "stack()" = "ancestors(reachable(@, mutable()), 2)";
        "stack(x)" = "ancestors(reachable(x, mutable()), 2)";
        "stack(x, n)" = "ancestors(reachable(x, mutable()), n)";

        # The current set of "open" works. It is defined as:
        #
        # - given the set of commits not in trunk, that are written by me,
        # - calculate the given stack() for each of those commits
        #
        # n = 1, meaning that nothing from `trunk()` is included, so all resulting
        # commits are mutable by definition.
        "open()" = "stack(trunk().. & mine(), 1)";

        # the set of 'ready()' commits. defined as the set of open commits, but nothing
        # that is blacklisted or any of their children.
        #
        # often used with gerrit, which you can use to submit whole stacks at once:
        #
        # - jj gerrit send -r 'ready()' --dry-run
        "ready()" = "open() ~ blacklist()::";
      };

      # colors = {
      #   # Base customizations
      #   "normal change_id" = "{ bold = true, fg = \"magenta\" }";
      #   "immutable change_id" = "{ bold = false, fg = \"bright cyan\" }";

      #   # Used by log node template
      #   "node" = "{ bold = true }";
      #   "node elided" = "{ fg = \"bright black\" }";
      #   "node working_copy" = "{ fg = \"green\" }";
      #   "node conflict" = "{ fg = \"red\" }";
      #   "node immutable" = "{ fg = \"bright cyan\" }";
      #   "node wip" = "{ fg = \"yellow\" }";
      #   "node normal" = "{ bold = false }";

      #   # Used in other various templates
      #   "text link" = "{ bold = true, fg = \"white\" }";
      #   "text warning" = "{ bold = true, fg = \"red\" }";
      # };
    };
  };
}
