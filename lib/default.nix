{inputs, withSystem, ...}:
# personal lib
let
  inherit (inputs.nixpkgs) lib;

  default = import ./theme {inherit lib;};
in {
  imports = [
    {
      _module.args = {
        inherit default;

        withSystemInputs = system:
          withSystem system ({
            self',
            inputs',
            ...
          }: [{_module.args = {inherit self' inputs';};}]);
      };
    }  ];

  perSystem = {system, ...}: {
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.overlays = [
        (
          _: prev: {
            steam = prev.steam.override {
              extraPkgs = pkgs:
                with pkgs; [
                  keyutils
                  libkrb5
                  libpng
                  libpulseaudio
                  libvorbis
                  stdenv.cc.cc.lib
                  xorg.libXcursor
                  xorg.libXi
                  xorg.libXinerama
                  xorg.libXScrnSaver
                ];
              extraProfile = "export GDK_SCALE=2";
            };
          }
        )
      ];
    };
  };
}
