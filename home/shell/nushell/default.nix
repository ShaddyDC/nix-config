{pkgs, ...}: {
  programs.nushell = {
    enable = true;
    # configFile.source = ./config.nu;
    # envFile.source = ./env.nu;
    extraConfig = let
      conf = builtins.toJSON {
        show_banner = false;

        ls.clickable_links = true;
        rm.always_trash = true;

        completions = {
          case_sensitive = false;
          quick = true;
          partial = true;
          algorithm = "fuzzy";
          use_ls_colors = true;
        };
      };
      completions = let
        completion = name: ''
          source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/${name}/${name}-completions.nu
        '';
      in
        names:
          builtins.foldl'
          (prev: str: "${prev}\n${str}") ""
          (map (name: completion name) names);
    in ''
      $env.config = ${conf};
      ${completions [
        # "cargo"
        "git"
        "nix"
        "npm"
        "poetry"
        "curl"
        "less"
        "make"
        "man"
        "tar"
        "bat"
        "gh"
        "just"
        "rg"
        "eza"
      ]}

      use ${pkgs.nu_scripts}/share/nu_scripts/modules/after/after.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/lg *
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/system *
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/docker *
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/jc *
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/background_task/task.nu

      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/7z.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/aws.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/caddy.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/du.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/feh.nu
      # use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/ffmpeg.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/file.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/find.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/flac.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/flatpak.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/fzf.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/g++.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/gcc.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/gdb.nu
      # use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/grep.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/hashcat.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/htop.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/hugo.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/ip.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/journalctl.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/jq.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/kill.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/latex.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/latexmk.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/mpv.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/ncat.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/nmap.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/pgrep.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/ping.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/realpath.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/set.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/systemctl.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/tee.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/traceroute.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/tsc.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/umount.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/unzip.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/auto-generate/completions/wget.nu
    '';
  };
}
