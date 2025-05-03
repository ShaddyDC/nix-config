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

      custom.jj = {
        detect_folders = [".jj"];
        command = "jj log --no-graph -r @ -n1 -T 'change_id.shortest() ++ \"|\" ++ if(empty, \"(empty) \") ++ description'";
        style = "cyan";
      };
    };

    enableNushellIntegration = true;
    enableBashIntegration = true;
  };
}
