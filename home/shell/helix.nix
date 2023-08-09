{
  pkgs,
  inputs',
  ...
}: {
  programs.helix = {
    enable = true;
    package = inputs'.helix.packages.default.overrideAttrs (self: {
      makeWrapperArgs = with pkgs;
        self.makeWrapperArgs
        or []
        ++ [
          "--suffix"
          "PATH"
          ":"
          (lib.makeBinPath [
            clang-tools
            marksman
            nil
            nodePackages.bash-language-server
            nodePackages.vscode-css-languageserver-bin
            nodePackages.vscode-langservers-extracted
            nodePackages.typescript-language-server
            shellcheck
            cmake-language-server
          ])
        ];
    });
    settings = {
      theme = "catppuccin_mocha";

      editor = {
        color-modes = true;
        cursorline = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render = true;
          rainbow-option = "dim";
        };
        lsp.display-inlay-hints = true;
        rainbow-brackets = true;
        statusline.center = ["position-percentage"];
        true-color = true;
        whitespace.characters = {
          newline = "↴";
          tab = "⇥";
        };
      };
      keys.normal.space.u = {
        C-F = ":format"; # format using LSP formatter
        # C-w = ":set whitespace.render all";
        # C-W = ":set whitespace.render none";
      };
    };
    languages = {
      language = [
        {
          name = "python";
          file-types = ["py"];
          language-servers = [{name = "pyright";}];
        }
        {
          name = "markdown";
          file-types = ["md"];
          language-servers = [{name = "marksman";} {name = "ltex";}];
        }
      ];
      language-server = {
        pyright = {
          command = "${pkgs.nodePackages.pyright}/bin/pyright-langserver";
          args = ["--stdio"];
          config = {};
        };
        ltex = {
          command = "${pkgs.ltex-ls}/bin/ltex-ls";
          args = [];
          configi = {};
        };
      };
    };
  };
}
