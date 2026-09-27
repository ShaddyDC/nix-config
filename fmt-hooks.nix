{inputs, ...}: {
  imports = [
    inputs.git-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    # `nix fmt` and the pre-commit hook run the same treefmt, so they can't
    # disagree about what counts as formatted.
    treefmt = {
      projectRootFile = "flake.nix";
      programs.alejandra.enable = true;

      # secrets/ is a submodule with its own repo and its own history; it is
      # only visible to treefmt when the flake is evaluated with
      # `?submodules=1`, so formatting it here would produce changes that
      # `nix fmt` in a plain worktree can't reproduce.
      settings.global.excludes = ["secrets/**"];
    };

    pre-commit.settings = {
      excludes = ["flake.lock" "^secrets/"];
      hooks.treefmt.enable = true;
    };
  };
}
