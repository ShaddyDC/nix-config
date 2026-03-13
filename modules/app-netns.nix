# Network namespace that bypasses Tailscale, for apps whose UDP sockets
# misbehave when tailscaled is running — notably Discord/Vesktop voice.
# See https://github.com/tailscale/tailscale/issues/10396.
{pkgs, ...}: let
  ns = "appns";
  vhost = "veth-host";
  vns = "veth-ns";
  subnet = "192.168.250";
  hostIp = "${subnet}.1";
  nsIp = "${subnet}.2";
  mtu = "1400";

  setupScript = pkgs.writeShellApplication {
    name = "app-netns-setup";
    runtimeInputs = with pkgs; [iproute2 iptables coreutils procps];
    text = ''
      sysctl -w net.ipv4.ip_forward=1 >/dev/null

      ip netns del ${ns} 2>/dev/null || true
      ip link del ${vhost} 2>/dev/null || true

      ip netns add ${ns}
      mkdir -p /etc/netns/${ns}
      echo "nameserver 1.1.1.1" > /etc/netns/${ns}/resolv.conf

      ip link add ${vhost} type veth peer name ${vns}
      ip link set ${vns} netns ${ns}

      ip link set dev ${vhost} mtu ${mtu}
      ip -n ${ns} link set dev ${vns} mtu ${mtu}

      ip addr add ${hostIp}/24 dev ${vhost}
      ip link set ${vhost} up

      ip -n ${ns} link set lo up
      ip -n ${ns} addr add ${nsIp}/24 dev ${vns}
      ip -n ${ns} link set ${vns} up
      ip -n ${ns} route add default via ${hostIp}

      # Interface-agnostic rules so eth0↔wifi swaps don't break egress.
      iptables -t nat -A POSTROUTING -s ${subnet}.0/24 ! -o ${vhost} -j MASQUERADE
      iptables -A FORWARD -i ${vhost} ! -o ${vhost} -j ACCEPT
      iptables -A FORWARD ! -i ${vhost} -o ${vhost} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      iptables -t mangle -A FORWARD -i ${vhost} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
    '';
  };

  teardownScript = pkgs.writeShellApplication {
    name = "app-netns-teardown";
    runtimeInputs = with pkgs; [iproute2 iptables coreutils];
    text = ''
      iptables -t mangle -D FORWARD -i ${vhost} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || true
      iptables -t nat -D POSTROUTING -s ${subnet}.0/24 ! -o ${vhost} -j MASQUERADE 2>/dev/null || true
      iptables -D FORWARD -i ${vhost} ! -o ${vhost} -j ACCEPT 2>/dev/null || true
      iptables -D FORWARD ! -i ${vhost} -o ${vhost} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
      ip netns pids ${ns} 2>/dev/null | xargs -r kill 2>/dev/null || true
      ip netns del ${ns} 2>/dev/null || true
      ip link del ${vhost} 2>/dev/null || true
      rm -rf /etc/netns/${ns}
    '';
  };

  runInNetns = pkgs.writeShellApplication {
    name = "run-in-appns";
    runtimeInputs = with pkgs; [iproute2 coreutils];
    text = ''
      USERN="$(id -un)"
      UIDN="$(id -u)"
      # Make sure session-bus vars are present even if the caller didn't export them
      export XDG_RUNTIME_DIR="/run/user/$UIDN"
      export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UIDN/bus"

      # Snapshot the full caller env so it survives both sudo hops.
      # Using -0 / mapfile handles values with spaces, quotes, newlines.
      mapfile -d "" -t envkv < <(env -0)

      exec /run/wrappers/bin/sudo ip netns exec ${ns} \
        /run/wrappers/bin/sudo -u "$USERN" env -i "''${envkv[@]}" "$@"
    '';
  };

  vesktopWrapper = pkgs.writeShellApplication {
    name = "vesktop-netns";
    runtimeInputs = [runInNetns];
    text = ''
      exec run-in-appns ${pkgs.vesktop}/bin/vesktop "$@"
    '';
  };

  vesktopDesktop = pkgs.makeDesktopItem {
    name = "vesktop-netns";
    desktopName = "Vesktop (no Tailscale)";
    exec = "vesktop-netns %U";
    icon = "vesktop";
    categories = ["Network" "InstantMessaging"];
    mimeTypes = ["x-scheme-handler/discord"];
  };
in {
  systemd.services.app-netns = {
    description = "Application network namespace (bypasses Tailscale)";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target" "tailscaled.service"];
    wants = ["network-online.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${setupScript}/bin/app-netns-setup";
      ExecStop = "${teardownScript}/bin/app-netns-teardown";
    };
  };

  environment.systemPackages = [runInNetns vesktopWrapper vesktopDesktop];
}
