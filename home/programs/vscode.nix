{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    profiles.default = {
      extensions = with pkgs;
      with vscode-extensions; [
        ms-vscode.cpptools
      ];
      userSettings = {
        editor.formatOnSave = true;
        C_Cpp.codeAnalysis.clangTidy.enabled = true;
        redhat.telemetry.enabled = false;
        "[typescript]".editor.defaultFormatter = "esbenp.prettier-vscode";
      };
    };
  };
}
