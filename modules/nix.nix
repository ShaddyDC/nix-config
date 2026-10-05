{
  config,
  pkgs,
  inputs,
  lib,
  self,
  ...
}: {
  # we need git for flakes
  environment.systemPackages = [pkgs.git];

  # nh wraps nixos-rebuild/gc with better output and a build diff, and
  # evaluates as the calling user, which the private git+ssh secrets input
  # needs (root has no GitHub key).
  programs.nh = {
    enable = true;
    flake = "/home/space/Documents/nix-config";
    clean = {
      enable = true;
      dates = "weekly";
      # Same 7d window as the nix.gc this replaces, but `--keep 3` guarantees
      # rollback targets survive even if the last 3 generations are all recent.
      extraArgs = "--keep 3 --keep-since 7d";
    };
  };
  # The module exports NH_FLAKE via environment.variables, i.e. only
  # /etc/set-environment, which bash/zsh source but nushell never does.
  # sessionVariables go through pam_env, so every login session gets it.
  environment.sessionVariables.NH_FLAKE = config.programs.nh.flake;

  # The timer is persistent, so a missed run fires while the laptop is in use.
  # Deprioritise it the same way nixpkgs already does for nix-optimise.
  systemd.services.nh-clean.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };

  nix = let
    # Inputs declared with `flake = false` are plain store paths, not flakes.
    # Mapping them into the registry produces a broken registry.json entry and
    # a bogus `<name>=flake:<name>` NIX_PATH component.
    flakeInputs = lib.filterAttrs (_: v: lib.isType "flake" v) inputs;
  in {
    # Deduplicate the store on a schedule rather than with auto-optimise-store,
    # which hard-links every path as it is built. That slows every build and,
    # with ext4's directory-index limit on the huge .links dir, causes the
    # "No space left on device" spam on builds.
    optimise = {
      automatic = true;
      dates = ["weekly"];
      persistent = true;
    };

    # pin the registry to avoid downloading and evaling a new nixpkgs version every time
    registry = lib.mapAttrs (_: v: {flake = v;}) flakeInputs;

    # set the path for channels compat
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

    settings = {
      builders-use-substitutes = true;
      experimental-features = ["nix-command" "flakes"];
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      # NB: no explicit priority on cache.nixos.org. It already advertises
      # Priority 40 in its nix-cache-info and the cachix mirrors advertise 41,
      # so it is preferred anyway; respelling it here would just add a second
      # store object for the same host and double the narinfo queries.
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = ["root" "@wheel"];
    };

    package = pkgs.nixVersions.stable;
  };

  # Use the custom legacyPackages instance (overlay + allowUnfree + permittedInsecure)
  nixpkgs.pkgs = self.legacyPackages.${config.nixpkgs.hostPlatform.system};

  # Use the system nixpkgs instance in home-manager: single eval, overlays/config flow through
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
