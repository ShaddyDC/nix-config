{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    extensions = with pkgs;
    with vscode-extensions; [
      ms-vscode.cpptools
    ];
  };
}
