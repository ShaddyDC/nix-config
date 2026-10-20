{inputs, ...}: let
  # Single overlay definition — exported as flake.overlays.default and applied to legacyPackages.
  overlay = final: prev: {
    claude-code = inputs.claude-code.packages.${prev.stdenv.hostPlatform.system}.default;
    tdl = inputs.toddledo.packages.${prev.stdenv.hostPlatform.system}.tdl;

    # TEMPORARY (NixOS/nixpkgs#576338): makeWrapper no longer accepts the
    # whole `--prefix PATH ...` as one argument; with that fixed, sphinx
    # still never writes the `man` output, so build only the HTML docs.
    # Drop once fixed upstream.
    afew = prev.afew.overridePythonAttrs {
      makeWrapperArgs = ["--prefix" "PATH" ":" "${final.notmuch}/bin"];
      sphinxBuilders = ["html"];
      outputs = ["out" "doc"];
    };

    # TEMPORARY: calibre's read-aloud stack doesn't build on current unstable
    # (piper-tts -> pyopenjtalk-plus, NixOS/nixpkgs#576442; and the speechd
    # module goes missing in calibre's own test). Text-to-speech is unused, so
    # drop it until those are fixed upstream.
    calibre = prev.calibre.override {speechSupport = false;};
  };
in {
  flake.overlays.default = overlay;

  # Custom nixpkgs instance, used by NixOS hosts via
  # `nixpkgs.pkgs = self.legacyPackages.${system}` (modules/nix.nix)
  perSystem = {system, ...}: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      # pnpm is currently flagged insecure but is pulled transitively.
      # Zotero bundles Firefox ESR 140 as its runtime, which went EOL on
      # 2026-10-13; drop this once nixpkgs' zotero moves to a newer ESR.
      config.permittedInsecurePackages = [
        "pnpm-10.34.0"
        "firefox-esr-140-bin-unwrapped-140.17.0esr"
      ];
      overlays = [overlay];
    };
  };
}
