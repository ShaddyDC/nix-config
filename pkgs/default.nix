{
  self,
  inputs,
  lib,
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

    obsidian_oop = lib.throwIf (lib.versionOlder "1.5.3" prev.obsidian.version) "Obsidian no longer requires EOL Electron" (
      prev.obsidian.override {
        electron = prev.electron_25.overrideAttrs (_: {
          preFixup = "patchelf --add-needed ${prev.libglvnd}/lib/libEGL.so.1 $out/bin/electron"; # NixOS/nixpkgs#272912
          meta.knownVulnerabilities = []; # NixOS/nixpkgs#273611
        });
      }
    );
  };

  perSystem = {pkgs, ...}: {
    packages = self.overlays.default inputs null pkgs;
  };
}
