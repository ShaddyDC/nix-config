{
  self,
  inputs,
  ...
}: {
  systems = ["x86_64-linux"];

  flake.overlays.default = _inputs: _: prev: {
    whisper-cpp = prev.callPackage ./whisper-cpp.nix {};

    xwayland = prev.xwayland.overrideAttrs (_: {
      patches = [
        ./patches/xwayland-vsync.patch
      ];
    });

   obsidian_oop = prev.obsidian.override { electron = prev.electron_26; };
  };

  perSystem = {pkgs, ...}: {
    packages = self.overlays.default inputs null pkgs;
  };
}
