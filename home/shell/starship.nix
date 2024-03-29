{...}: {
  programs.starship = {
    enable = true;

    settings = {
      character = {
        success_symbol = "[›](bold green)";
        error_symbol = "[›](bold red)";
      };

      git_status = {
        deleted = "✗";
        modified = "✶";
        staged = "✓";
        stashed = "≡";
      };

      nix_shell = {
        symbol = " ";
        heuristic = true;
      };

      aws.disabled = true;
    };

    enableNushellIntegration = true;
    enableBashIntegration = true;
  };
}
