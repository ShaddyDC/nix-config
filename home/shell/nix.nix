{
  config,
  lib,
  pkgs,
  ...
}:
# nix tooling
{
  home.packages = with pkgs; [
    alejandra
    deadnix
    statix
    manix
    nix-du
    # self.packages.${pkgs.hostPlatform.system}.repl
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableBashIntegration = true;
    # Replaced by the hook below.
    enableNushellIntegration = false;
  };

  # HM's hook, except that it skips variables differing only in case from one
  # already set. Nushell's $env is case-insensitive, so a dev shell's lowercase
  # `shell` (stdenv's minimal bash) overwrote SHELL on entering and deleted it
  # on leaving. `nix shell` then started that bash, without readline or
  # `complete`.
  programs.nushell.extraConfig = lib.mkAfter ''
    $env.config = ($env.config? | default {})
    $env.config.hooks = ($env.config.hooks? | default {})
    $env.config.hooks.pre_prompt = (
        $env.config.hooks.pre_prompt?
        | default []
        | append {||
            let raw = (
                ${lib.getExe config.programs.direnv.package} export json
                | from json --strict
                | default {}
            )
            let present = ($env | columns)
            let lower = ($present | str lowercase)
            let direnv = (
                $raw
                | reject ...($raw | columns | where {|k| $k not-in $present and ($k | str lowercase) in $lower })
            )

            for key in ($direnv | columns) {
                if ($direnv | get $key) == null {
                    hide-env --ignore-errors $key
                }
            }

            $direnv
            | items {|key, value|
                let value = do (
                    {
                      "PATH": {
                        from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
                        to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
                      }
                    }
                    | merge ($env.ENV_CONVERSIONS? | default {})
                    | get ([[value, optional, insensitive]; [$key, true, true] [from_string, true, false]] | into cell-path)
                    | if ($in | is-empty) { {|x| $x} } else { $in }
                ) $value
                return [ $key $value ]
            }
            | where {|pair| $pair.1 != null }
            | into record
            | load-env
        }
    )
  '';
}
