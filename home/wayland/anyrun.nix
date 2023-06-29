{inputs', ...}: {
  programs.anyrun = {
    enable = true;
    config = {
      plugins = [
        inputs'.anyrun.packages.applications
        "${inputs'.anyrun.packages.anyrun-with-all-plugins}/lib/libapplications.so"
        "${inputs'.anyrun.packages.anyrun-with-all-plugins}/lib/libdictionary.so"
        "${inputs'.anyrun.packages.anyrun-with-all-plugins}/lib/libkidex.so"
        "${inputs'.anyrun.packages.anyrun-with-all-plugins}/lib/librandr.so"
        "${inputs'.anyrun.packages.anyrun-with-all-plugins}/lib/librink.so"
        "${inputs'.anyrun.packages.anyrun-with-all-plugins}/lib/libshell.so"
        "${inputs'.anyrun.packages.anyrun-with-all-plugins}/lib/libstdin.so"
        "${inputs'.anyrun.packages.anyrun-with-all-plugins}/lib/libsymbols.so"
        "${inputs'.anyrun.packages.anyrun-with-all-plugins}/lib/libtranslate.so"
      ];
      width = {fraction = 0.3;};
      position = "top";
      verticalOffset = {absolute = 15;};
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = true;
      showResultsImmediately = false;
      maxEntries = null;
    };
    extraCss = ''
      * {
        transition: 200ms ease-out;
        font-family: Lexend;
        font-size: 1.3rem;
      }

      #window,
      #match,
      #entry,
      #plugin,
      #main {
        background: transparent;
      }

      #match:selected {
        background: rgba(203, 166, 247, 0.7);
      }

      #match {
        padding: 3px;
        border-radius: 16px;
      }

      #entry {
        border-radius: 16px;
      }

      box#main {
        background: rgba(30, 30, 46, 0.7);
        border: 1px solid #28283d;
        border-radius: 24px;
        padding: 8px;
      }

      row:first-child {
        margin-top: 6px;
      }
    '';

    extraConfigFiles."some-plugin.ron".text = ''
      Config(
        // for any other plugin
        // this file will be put in ~/.config/anyrun/some-plugin.ron
        // refer to docs of xdg.configFile for available options
      )
    '';
  };
}
