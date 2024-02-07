{
  pkgs,
  inputs',
  lib,
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
            nodePackages.vue-language-server
            nodePackages.dockerfile-language-server-nodejs
            (
              pkgs.writeShellScriptBin "vue-language-server" ''
                exec ${pkgs.nodePackages.vue-language-server}/bin/vls "$@"
              ''
            )
            nodePackages.yaml-language-server
            shellcheck
            cmake-language-server
            rust-analyzer-unwrapped
            taplo
          ])
        ];
    });
    settings = {
      theme = lib.mkForce "catppuccin_mocha";

      editor = {
        color-modes = true;
        cursorline = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
        lsp.display-inlay-hints = true;
        statusline.center = ["position-percentage"];
        true-color = true;
        whitespace.characters = {
          newline = "↴";
          tab = "⇥";
        };
      };
      # https://theari.dev/blog/enhanced-helix-config/ TODO
      keys.normal = {
        space.c = ":bc";
        C-f = ":format";
        space.u = {
          w = ":set whitespace.render all";
          W = ":set whitespace.render none";
        };
      };
    };
    languages = {
      language = let
        prettier = lang: {
          command = "${pkgs.nodePackages.prettier}/bin/prettier";
          args = ["--parser" lang];
        };
      in
        [
          {
            name = "bash";
            auto-format = true;
            formatter = {
              command = "${pkgs.shfmt}/bin/shfmt";
              args = ["-i" "2" "-"];
            };
          }
          {
            name = "python";
            file-types = ["py"];
            language-servers = ["pyright" "ruff"];
          }
          {
            name = "markdown";
            file-types = ["md"];
            language-servers = ["marksman" "ltex"];
          }
          {
            name = "javascript";
            auto-format = true;
            language-servers = ["eslint" "typescript-language-server"];
            formatter = prettier "javascript";
          }
          {
            name = "typescript";
            auto-format = true;
            language-servers = ["eslint" "typescript-language-server"];
            formatter = prettier "typescript";
          }
        ]
        ++ (
          let
            prettierLangs = map (e: {
              name = e;
              formatter = prettier e;
            });
            langs = ["css" "scss" "json" "html"];
          in (prettierLangs langs)
        );
      language-server = {
        pyright = {
          command = "${pkgs.nodePackages.pyright}/bin/pyright-langserver";
          args = ["--stdio"];
          config = {};
        };
        ruff = {
          command = "${pkgs.python311Packages.ruff-lsp}/bin/ruff-lsp";
          config = {};
        };
        ltex = {
          command = "${pkgs.ltex-ls}/bin/ltex-ls";
          args = [];
          configi = {};
        };
        bash-language-server = {
          command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
          args = ["start"];
        };
        eslint = {
          command = "${pkgs.nodePackages.eslint}/bin/eslint";
          args = ["--stdin"];
        };
        typescript-language-server = {
          command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
          args = ["--stdio"];
        };

        clangd = {
          command = "${pkgs.clang-tools}/bin/clangd";
          clangd.fallbackFlags = ["-std=c++2b"];
        };

        nil = {
          command = lib.getExe pkgs.nil;
          config.nil.formatting.command = ["${lib.getExe pkgs.alejandra}" "-q"];
        };

        vscode-css-language-server = {
          command = "${pkgs.nodePackages.vscode-css-languageserver-bin}/bin/css-languageserver";
          args = ["--stdio"];
          config = {
            provideFormatter = true;
            css.validate.enable = true;
            scss.validate.enable = true;
          };
        };
      };
    };
  };
}
