# pclaude: Claude Code against Privatemode (privatemode.ai) instead of
# Anthropic. Inference runs on open-weight models in confidential-computing
# enclaves; the local proxy checks their remote attestation before anything is
# sent, and encrypts each request to the attested deployment. The proxy holds no
# API key: pclaude sends it per request, so the container is safe to leave
# running. With these settings Claude Code opens no connection but the proxy
# (checked with strace on 2026-10-25); WebSearch does not exist off Anthropic's
# API, so search is Kagi over Privacy Pass instead (kagi-pp-search, an MCP
# server); it and WebFetch run on this machine, so egress follows the host's VPN.
{
  config,
  inputs,
  pkgs,
  ...
}: let
  port = "8749";
  # Renovate bumps this (customManagers in renovate.json: keep the line's shape).
  # The digest is the multi-arch index's. A proxy that falls too far behind can
  # stop matching the deployment's manifest.
  image = "ghcr.io/edgelesssys/privatemode/privatemode-proxy:v1.60.0@sha256:ea044948f9ee427ba8eff07a489e1105f20170e3e8c42b9800d8adaf065b24b3";

  kagi = inputs.kagi-pp-search.packages.${pkgs.stdenv.hostPlatform.system}.default;
  kagiSession = config.age.secrets.kagi-session.path;

  mcpConfig = pkgs.writeText "pclaude-mcp.json" (builtins.toJSON {
    mcpServers.kagi = {
      command = "${kagi}/bin/kagi-pp-search";
      args = ["mcp"];
      env.KAGI_SESSION_FILE = kagiSession;
    };
  });

  settings = pkgs.writeText "pclaude-settings.json" (builtins.toJSON {
    # The domain check before every WebFetch goes to api.anthropic.com
    skipWebFetchPreflight = true;
    disableClaudeAiConnectors = true;
    # Server-side tool that only Anthropic's API runs: hide it so the model
    # uses WebFetch instead of calling something that cannot work
    permissions.deny = ["WebSearch"];
    # Read-only, and each call is one Privacy Pass token: no classifier round
    permissions.allow = ["mcp__kagi__web_search"];
  });

  pclaude = pkgs.writeShellApplication {
    name = "pclaude";
    runtimeInputs = [pkgs.claude-code pkgs.curl config.virtualisation.podman.package kagi];
    text = ''
      key="$(cat ${config.age.secrets.privatemode-api-key.path})"
      base="http://127.0.0.1:${port}"

      if [ "''${1:-}" = "--stop-proxy" ]; then
        exec podman stop privatemode-proxy
      fi

      healthy() {
        curl -sf -o /dev/null -H "authorization: Bearer $key" "$base/v1/models"
      }

      if ! healthy; then
        if [ "$(podman inspect -f '{{.State.Running}}' privatemode-proxy 2>/dev/null)" != true ]; then
          # Prompt cache on, with a random salt per proxy start: cached input is
          # a tenth of the price, and the salt keeps the cache to this proxy.
          podman run -d --rm --replace --name privatemode-proxy \
            -p "127.0.0.1:${port}:8080" ${image} \
            --api-key-fallback never --disable-prompt-cache=false >/dev/null
        fi
        # Startup includes the attestation check: if it never turns healthy,
        # `podman logs privatemode-proxy` says why
        for _ in $(seq 60); do healthy && break; sleep 0.5; done
        healthy || { echo "pclaude: privatemode-proxy not healthy, see: podman logs privatemode-proxy" >&2; exit 1; }
      fi

      # Top the Kagi token stash up now rather than mid-session, and show what
      # is left; offline or over quota only costs search, not the session
      if ! KAGI_SESSION_FILE=${kagiSession} kagi-pp-search refill --quiet; then
        echo "pclaude: Kagi token refill failed, search may not work" >&2
      fi
      kagi-pp-search status >&2

      unset ANTHROPIC_API_KEY
      export ANTHROPIC_BASE_URL="$base"
      export ANTHROPIC_AUTH_TOKEN="$key"
      model="''${PCLAUDE_MODEL:-glm-5.3}"
      export ANTHROPIC_MODEL="$model"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="$model"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="$model"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL=glm-5.3-flash
      export CLAUDE_CODE_SUBAGENT_MODEL="$model"
      # Auto mode's permission classifier, which defaults to the main model and
      # gives up after 60 s. GLM-5.3 here always reasons at max effort: one
      # verdict took 107 s, Flash 15 s, gpt-oss-120b 2 s (2026-10-25).
      export CLAUDE_CODE_AUTO_MODE_MODEL=gpt-oss-120b
      # GLM-5.3 takes 1M, but compacting at 200k keeps a turn's cost bounded
      export CLAUDE_CODE_MAX_CONTEXT_TOKENS=200000
      export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
      export CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY=1
      export CLAUDE_CODE_DISABLE_OFFICIAL_MARKETPLACE_AUTOINSTALL=1
      # Own config dir: no claude.ai login, memory, plugins or history shared
      # with the normal claude
      export CLAUDE_CONFIG_DIR="$HOME/.claude-private"

      # Only this MCP server: nothing from the normal claude's config
      exec claude --settings ${settings} --mcp-config ${mcpConfig} --strict-mcp-config "$@"
    '';
  };
in {
  age.secrets.privatemode-api-key = {
    file = inputs.secrets + "/privatemode-api-key.age";
    owner = config.users.users.space.name;
  };

  age.secrets.kagi-session = {
    file = inputs.secrets + "/kagi-session.age";
    owner = config.users.users.space.name;
  };
  # `kagi-pp-search status` and friends from a shell too
  environment.sessionVariables.KAGI_SESSION_FILE = kagiSession;

  environment.systemPackages = [pclaude kagi];
}
