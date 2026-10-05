# nix-config

My personal nix system config.
Mainly intended for personal use.

## Hosts

- `framework` – laptop
- `spacedesktop` – desktop

## Secrets

This repo is public. Secrets (agenix files, mail accounts, the font) live in
the private `nix-secrets` repo, which the flake pulls in as the `secrets`
`git+ssh` input. Its working clone sits gitignored at `./secrets`.

After changing it: commit and push, then `nix flake update secrets`. To try a
change before pushing, pass `--override-input secrets ./secrets`.

## Rebuilding

```sh
nh os switch            # or: ./switch switch
nh os boot / test / build
```

nh evaluates as your user, which the private input needs: root has no GitHub
key, so a plain `sudo nixos-rebuild` can't fetch it.
