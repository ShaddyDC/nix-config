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
      # The private clone at ./secrets is gitignored, and treefmt only walks
      # files git tracks, so it is left alone.
    };

    pre-commit.settings = {
      excludes = ["flake.lock"];
      hooks.treefmt.enable = true;
    };
  };
}
