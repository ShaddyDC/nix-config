{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    extensions = (with pkgs;
      with vscode-extensions; [
        ms-vscode.cpptools
      ]);
  };

}
