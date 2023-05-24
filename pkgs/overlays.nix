inputs: _: prev: {
  whisper-cpp = prev.callPackage ./whisper-cpp.nix {};

  xwayland = prev.xwayland.overrideAttrs (_: {
    patches = [
      ./patches/xwayland-vsync.patch
    ];
  });
}
