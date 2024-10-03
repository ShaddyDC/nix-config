{
  pkgs,
  inputs',
  lib,
  ...
}: {
  programs.helix = {
    enable = true;
    package = inputs'.helix.packages.default;
    extraPackages = with pkgs; [
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
      superhtml
    ];
    settings = {
      theme = lib.mkForce "catppuccin_mocha";

      editor = {
        color-modes = true;
        completion-trigger-len = 1;
        completion-replace = true;
        cursorline = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "error";
        };
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
        space.n = [
          ":pipe llm -s \"'Return me the code I give you with fixes, completions, and comments. Do not put a code block around it, and do not add any extra commentary outside the code. Only return the code with your modifications.'\" -m claude-3-haiku"
        ];
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
            language-servers = ["ruff" "basedpyright"];
            formatter = {
              command = lib.getExe pkgs.ruff;
              args = ["format" "-"];
            };

            auto-format = true;
          }
          {
            name = "markdown";
            auto-format = true;
            file-types = ["md"];
            language-servers = ["dprint" "marksman" "ltex"];
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
            language-servers = ["vue-language-server" "eslint"];
            formatter = prettier "vue";
          }
          {
            name = "yaml";
            auto-format = true;
            formatter = {
              command = lib.getExe pkgs.yamlfmt;
              args = [
                "-in"
                "-no_global_conf"
              ];
            };
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
        basedpyright.command = "${pkgs.basedpyright}/bin/basedpyright-langserver";
        ruff = {
          command = lib.getExe pkgs.ruff;
          args = ["server"];
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
          config = {
            typescript-language-server.source = {
              addMissingImports.ts = true;
              fixAll.ts = true;
              organizeImports.ts = true;
              removeUnusedImports.ts = true;
              sortImports.ts = true;
            };
          };
        };
        vue-language-server = {
          command = lib.getExe pkgs.vue-language-server;
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
          command = "${pkgs.nodePackages.vscode-langservers-extracted}/bin/vscode-css-languageserver";
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

  home.file.".dprint.json".source = builtins.toFile "dprint.json" (builtins.toJSON {
    lineWidth = 100;
    # This applies to both JavaScript & TypeScript
    typescript = {
      quoteStyle = "preferSingle";
      binaryExpression.operatorPosition = "sameLine";
    };
    json.indentWidth = 2;
    excludes = [
      "**/*-lock.json"
    ];
    plugins = [
      "https://plugins.dprint.dev/typescript-0.93.0.wasm"
      "https://plugins.dprint.dev/json-0.19.3.wasm"
      "https://plugins.dprint.dev/markdown-0.17.8.wasm"
      "https://plugins.dprint.dev/toml-0.6.3.wasm"
    ];
  });
}
