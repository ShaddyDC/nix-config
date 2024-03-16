{
  config,
  lib,
  pkgs,
  ...
}:
# https://github.com/bqv/rc/blob/7fb53a24e416142e1909e87d19727b6ef4f43236/modules/services/hydroxide/default.nix
let
  cfg = config.services.hydroxide;
in {
  options.services.hydroxide = {
    enable = lib.mkEnableOption "hydroxide";

    userauths = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {};
      description = ''
        Authentication data of registered users
      '';
    };

    host = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Host to bind to
      '';
    };

    port = lib.mkOption {
      type = with lib.types; nullOr int;
      default = null;
      description = ''
        Port to bind to
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.hydroxide;
      defaultText = "pkgs.hydroxide";
      description = ''
        Which package to use.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    systemd.services.hydroxide = rec {
      enable = true;
      after = ["network.target"];
      description = "Hydroxide bridge server";
      environment.XDG_CONFIG_HOME = "/var/lib/${serviceConfig.StateDirectory}";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "hydroxide";
        ExecStartPre = let
          authFile = builtins.toJSON cfg.userauths;
        in
          pkgs.writers.writeDash "hydroxide-start-pre" ''
            mkdir ${environment.XDG_CONFIG_HOME}/hydroxide/
            ${pkgs.coreutils}/bin/ln -sf ${pkgs.writeText "auth.json" authFile} ${environment.XDG_CONFIG_HOME}/hydroxide/auth.json
          '';
        ExecStart = let
          hostOpts =
            if isNull cfg.host
            then ""
            else let
              inherit (cfg) host;
            in "-imap-host ${host} -smtp-host ${host} -carddav-host ${host}";
          portOpts =
            if isNull cfg.port
            then ""
            else let
              inherit (cfg) port;
            in "-imap-port ${builtins.toString port} -smtp-port ${builtins.toString port} -carddav-port ${builtins.toString port}";
          args = lib.concatStringsSep " " [hostOpts portOpts];
        in ''
          ${cfg.package}/bin/hydroxide ${args} -debug serve
        '';
        Restart = "always";
        RestartSec = 15;
      };
    };
  };
}
