{...}: {
  programs.kitty = {
    enable = true;
    settings = {
      scrollback_lines = 10000;
      placement_strategy = "center";

      allow_remote_control = "yes";
      enable_audio_bell = "no";
      visual_bell_duration = "0.1";

      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";
      shell_integration = "enabled";

      # DMS window integration
      hide_window_decorations = "yes";
      window_padding_width = 12;
      background_opacity = "1.0";
      background_blur = 32;

      cursor_shape = "block";
      cursor_blink_interval = 1;

      "map ctrl+n" = "new_os_window_with_cwd";
    };
    extraConfig = ''
      # Colours come from DMS, which writes these at runtime
      include dank-tabs.conf
      include dank-theme.conf
    '';
  };
}
