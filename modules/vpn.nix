{
  pkgs,
  config,
  lib,
  ...
}:
# Partly inspired by
# https://github.com/delroth/infra.delroth.net/blob/1e1ef1cd64a8fc53f77d4b13e0742b2741e90db9/services/wg-netns.nix#L161
# https://mth.st/blog/nixos-wireguard-netns/
# https://github.com/existentialtype/deluge-namespaced-wireguard
let
  cfg = config.netns-wg;
in {
  options.netns-wg = with lib; {
    enable = mkEnableOption "Wireguard netns";

    isolateServices = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            enable = mkEnableOption "Whether to enable this service";
            forwardPorts = mkOption {
              type = types.listOf types.port;
              default = [];
              description = ''
                Port numbers that services listen on in the Wireguard netns and that
                should be exposed (listening on ::1 only) in the outer netns.
              '';
            };
          };
        });

      default = {};

      description = ''
        Names of systemd services to "patch" to force them to run inside the
        Wireguard network namespace.
      '';
    };

    private-key = mkOption {
      type = types.path;
    };
    peer = mkOption {
      type = types.str;
    };
    endpoint = mkOption {
      type = types.str;
    };
    address-ipv4 = mkOption {
      type = types.str;
    };
    gateway = mkOption {
      type = types.str;
    };
    dns = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable (with cfg; let
    resolvconf = pkgs.writeText "wg-resolv.conf" "nameserver ${dns}";
    nsswitchconf = pkgs.writeText "wg-nsswitch.conf" "hosts: files dns";
    enableService = service: {
      bindsTo = ["wg.service"];
      after = ["wg.service"];
      serviceConfig = {
        NetworkNamespacePath = "/var/run/netns/wg";

        BindReadOnlyPaths = [
          "${resolvconf}:/etc/resolv.conf"
          "${nsswitchconf}:/etc/nsswitch.conf"
        ];
      };
    };
    forwardSocket = service: port: {
      name = "netns-${service}-forward-${toString port}";
      value = {
        bindsTo = ["wg.service"];
        after = ["wg.service"];
        socketConfig = {
          ListenStream = port;
        };
      };
    };
    forwardService = service: port: rec {
      name = "netns-${service}-forward-${toString port}";
      value = {
        bindsTo = ["${service}.service" "${name}.socket"];
        after = ["${service}.service" "${name}.socket"];
        wantedBy = ["${service}.service"];
        serviceConfig = {
          NetworkNamespacePath = "/var/run/netns/wg";
          ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString port}";
        };
      };
    };

    processServices =
      builtins.mapAttrs (serviceName: serviceConfig: {
        systemdConfig = enableService serviceName;
        socketUnits = map (forwardSocket serviceName) serviceConfig.forwardPorts;
        serviceUnits = map (forwardService serviceName) serviceConfig.forwardPorts;
      })
      cfg.isolateServices;

    allSocketUnits = builtins.listToAttrs (builtins.concatLists (lib.mapAttrsToList (name: config: config.socketUnits) processServices));
    allServiceUnits =
      builtins.listToAttrs (builtins.concatLists (lib.mapAttrsToList (name: config: config.serviceUnits) processServices))
      // (builtins.mapAttrs (_: svc: svc.systemdConfig) processServices);

    # TODO fix, always prints all
    enabledServices = lib.traceVal (lib.filterAttrs (name: service: service.enable) cfg.isolateServices);
    isServiceEnabled = name: builtins.hasAttr name config.systemd.services && config.systemd.services.${name}.enable;
    disabledServiceNames = lib.traceVal (builtins.filter (name: !isServiceEnabled name) (builtins.attrNames enabledServices));
    checkEnabledServices = {
      assertion = lib.traceVal (disabledServiceNames == []);
      message = "The following services specified in netns-wg are not enabled in systemd.services: " + builtins.concatStringsSep ", " disabledServiceNames;
    };

    services = {
      "netns@" = {
        description = "%I network namespace";
        # Delay network.target until this unit has finished starting up.
        before = ["network.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.writers.writeDash "netns-up" ''
            ${pkgs.iproute2}/bin/ip netns add $1
          ''} %I";
          ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
        };
      };

      wg = {
        description = "wg network interface";
        bindsTo = ["netns@wg.service"];
        requires = ["network-online.target" "nss-lookup.target"];
        after = ["netns@wg.service" "network-online.target" "nss-lookup.target"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writers.writeDash "wg-up" ''
            set -e
            ${pkgs.iproute2}/bin/ip link add wg0 type wireguard
            ${pkgs.wireguard-tools}/bin/wg set wg0 \
              private-key ${private-key} \
              peer ${peer} \
              allowed-ips 0.0.0.0/0,::/0 \
              endpoint ${endpoint}
            ${pkgs.iproute2}/bin/ip link set wg0 netns wg
            ${pkgs.iproute2}/bin/ip -n wg link set wg0 up
            ${pkgs.iproute2}/bin/ip -n wg link set lo up
            ${pkgs.iproute2}/bin/ip -n wg address add ${address-ipv4} dev wg0
            ${pkgs.iproute2}/bin/ip -n wg route add ${gateway} dev wg0
            ${pkgs.iproute2}/bin/ip -n wg route add default via ${gateway}
          '';
          ExecStop = pkgs.writers.writeDash "wg-down" ''
            ${pkgs.iproute2}/bin/ip -n wg route del default
            ${pkgs.iproute2}/bin/ip -n wg -6 route del default dev wg0
            ${pkgs.iproute2}/bin/ip -n wg link del wg0
          '';
        };
      };
    };
  in {
    assertions = [checkEnabledServices];

    systemd = {
      services = lib.traceVal (services // allServiceUnits);
      sockets = lib.traceVal allSocketUnits;
    };
  });
}
