{pkgs, ...}: {
  programs.nushell = {
    enable = true;

    # Assigned key by key. A wholesale `$env.config = {...}` in extraConfig
    # used to wipe what other modules had set before it, such as nix-index's
    # command_not_found hook.
    settings = {
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

    extraConfig = ''
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/after/after.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/lg *
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/system *
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/docker *
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/jc *
    '';
  };

  # Completions for external commands, replacing the hand-picked nu_scripts
  # completion files. Covers ~1000 tools, including jj, nh, podman and
  # tailscale, which the old list did not.
  programs.carapace.enable = true;
}
