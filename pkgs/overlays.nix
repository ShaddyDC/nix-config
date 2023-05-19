inputs: _: prev: {
  xwayland = prev.xwayland.overrideAttrs (_: {
    patches = [
      ./patches/xwayland-vsync.patch
    ];
  });
}
