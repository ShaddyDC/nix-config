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
            bash-language-server
            vscode-langservers-extracted
            nodePackages.vscode-langservers-extracted
            nodePackages.typescript-language-server
            vue-language-server
            nodePackages.dockerfile-language-server-nodejs
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
          command = lib.getExe pkgs.nodePackages.prettier;
          args = ["--parser" lang];
        };
      in
        [
          {
            name = "bash";
            auto-format = true;
            formatter = {
              command = lib.getExe pkgs.shfmt;
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
          {
            name = "vue";
            auto-format = true;
            language-servers = ["eslint" "vue-language-server"];
            formatter = prettier "vue";
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
          command = "${pkgs.pyright}/bin/pyright-langserver";
          args = ["--stdio"];
          config = {};
        };
        ruff = {
          command = lib.getExe pkgs.ruff-lsp;
          config = {};
        };
        ltex = {
          command = lib.getExe pkgs.ltex-ls;
          args = [];
          configi = {};
        };
        bash-language-server = {
          command = lib.getExe pkgs.bash-language-server;
          args = ["start"];
        };
        eslint = {
          command = lib.getExe pkgs.nodePackages.eslint;
          args = ["--stdin"];
        };
        typescript-language-server = {
          command = lib.getExe pkgs.nodePackages.typescript-language-server;
          args = ["--stdio"];
        };
        vue-language-server = {
          command = lib.getExe pkgs.nodePackages_latest.vue-language-server;
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
          command = lib.getExe pkgs.nodePackages.vscode-langservers-extracted ;
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
