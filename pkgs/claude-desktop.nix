# Claude Desktop, packaged from Anthropic's *official* Linux .deb (apt repo at
# downloads.claude.ai). This replaces the previous approach of wrapping the
# macOS DMG (stslex/claude-desktop-linux): the native Linux build ships its own
# Linux subprocess helper, so none of the macOS shims — or the passthrough
# `disclaimer` shim we needed before — are required here.
#
# Adapted from nixpkgs PR #537215 (minegameYTB, "claude-desktop: init"), with:
#   - version bumped to the current apt-repo release,
#   - passwordStore defaulted by the caller (gnome-libsecret on Wayland/Hyprland,
#     otherwise sign-in isn't persisted — see PR discussion),
#   - GTK dark theme + GPU libs folded into the wrapper.
#
# The whole thing is wrapped in buildFHSEnv on purpose: Cowork/agent mode
# self-downloads a stock generic-linux Claude Code CLI to
# ~/.config/Claude/claude-code/<ver>/claude and execs it by absolute path; only
# an FHS glibc loader (or nix-ld) lets it run. The FHS env also carries the
# QEMU/OVMF/virtiofsd Cowork VM backend and the /dev/kvm + vhost passthrough.
{
  lib,
  fetchurl,
  stdenvNoCC,
  buildFHSEnv,

  ### Tools
  dpkg,
  autoPatchelfHook,
  makeWrapper,

  ### Electron/Chromium
  nss,
  nspr,
  mesa,
  libglvnd,
  alsa-lib,
  libxkbcommon,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  at-spi2-atk,
  at-spi2-core,
  cups,
  dbus,
  gtk3,
  pango,
  cairo,
  expat,
  glib,
  systemd,

  ### For virtiofsd
  libseccomp,
  libcap_ng,

  ### For keyring support
  libsecret,

  ### For Cowork QEMU
  qemu,
  OVMF,

  ### For extensions
  python3,
  nodejs,

  ### Force a specific password store backend (e.g. "gnome-libsecret" for
  ### non-GNOME/KDE DEs, otherwise Electron falls back to a plaintext store and
  ### sign-in is not persisted).
  passwordStore ? null,
}: let
  unwrapped = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "claude-desktop";
    version = "1.17377.2";

    src =
      if stdenvNoCC.hostPlatform.system == "x86_64-linux"
      then
        fetchurl {
          url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_amd64.deb";
          hash = "sha256-7AjUGqeYjS06P19P/fONIHtBLmYmOfQNeiZbivriEqs=";
        }
      else if stdenvNoCC.hostPlatform.system == "aarch64-linux"
      then
        fetchurl {
          url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_arm64.deb";
          hash = lib.fakeHash;
        }
      else throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = [
      ### Electron/Chromium
      nss
      nspr
      mesa
      libglvnd
      alsa-lib
      libxkbcommon
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      at-spi2-atk
      at-spi2-core
      cups
      dbus
      gtk3
      pango
      cairo
      expat
      glib
      systemd

      ### Bundled virtiofsd
      libseccomp
      libcap_ng

      ### For keyring support
      libsecret

      ### For Cowork QEMU
      qemu
      OVMF.fd

      ### For extensions
      python3
      nodejs
    ];

    unpackPhase = ''
      runHook preUnpack

      dpkg-deb --fsys-tarfile $src | tar --extract

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      mv usr/* $out

      runHook postInstall
    '';

    postFixup = ''
      wrapProgram $out/bin/claude-desktop \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [libsecret libglvnd]}:/run/opengl-driver/lib \
        --prefix PATH : ${lib.makeBinPath [python3 nodejs]} \
        --set-default GTK_THEME "Adwaita:dark" \
        ${lib.optionalString (passwordStore != null) ''
        --add-flags "--password-store=${passwordStore}"
      ''}
    '';

    meta = {
      description = "Desktop application for Claude.ai (official Linux build)";
      homepage = "https://claude.ai/download";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux" "aarch64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = "claude-desktop";
    };
  });

  fhsEnv = buildFHSEnv {
    pname = "claude-desktop-fhsenv";
    inherit (unwrapped) version;

    targetPkgs = pkgs:
      with pkgs; [
        unwrapped
        glibc
        qemu
        python3
        nodejs
        libsecret
        libglvnd
      ];

    extraBuildCommands =
      ''
        ### OVMF firmware (hardcoded lookup paths in the app.asar). Cowork picks
        ### the *_4M variant and derives the VARS template name from the CODE
        ### name, so OVMF_VARS_4M.fd must exist too or VM boot fails with
        ### "read EFI vars template: ... OVMF_VARS_4M.fd: no such file". nixpkgs
        ### OVMF is already a 4M build, so all four are aliases of the same pair.
        mkdir -p "$out/usr/share/OVMF"
        ln -s ${OVMF.fd}/FV/OVMF_CODE.fd  "$out/usr/share/OVMF/OVMF_CODE.fd"
        ln -s ${OVMF.fd}/FV/OVMF_CODE.fd  "$out/usr/share/OVMF/OVMF_CODE_4M.fd"
        ln -s ${OVMF.fd}/FV/OVMF_VARS.fd  "$out/usr/share/OVMF/OVMF_VARS.fd"
        ln -s ${OVMF.fd}/FV/OVMF_VARS.fd  "$out/usr/share/OVMF/OVMF_VARS_4M.fd"

        ### virtiofsd fallback paths (hardcoded in the app.asar)
        mkdir -p "$out/usr/libexec" "$out/usr/bin"
        ln -s ${unwrapped}/lib/claude-desktop/resources/virtiofsd "$out/usr/libexec/virtiofsd"
        ln -s ${unwrapped}/lib/claude-desktop/resources/virtiofsd "$out/usr/bin/virtiofsd"
      ''
      + lib.optionalString stdenvNoCC.hostPlatform.isAarch64 ''
        ### AAVMF firmware (used when process.arch = "arm64")
        mkdir -p "$out/usr/share/AAVMF"
        ln -s ${OVMF.fd}/FV/AAVMF_CODE.fd  "$out/usr/share/AAVMF/AAVMF_CODE.fd"
        ln -s ${OVMF.fd}/FV/AAVMF_VARS.fd  "$out/usr/share/AAVMF/AAVMF_VARS.fd"
      '';

    ### Cowork's VM sandbox launches the bundled QEMU *inside* the FHS sandbox,
    ### so the virtualization device nodes must be passed through.
    extraBwrapArgs = [
      "--dev-bind-try /dev/kvm /dev/kvm"
      "--dev-bind-try /dev/vhost-vsock /dev/vhost-vsock"
      "--dev-bind-try /dev/vhost-net /dev/vhost-net"
      "--dev-bind-try /dev/net/tun /dev/net/tun"
    ];

    extraInstallCommands = ''
      mkdir -p "$out/share"
      ln -s ${unwrapped}/share/* "$out/share/"
    '';

    runScript = "${unwrapped}/bin/claude-desktop";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "claude-desktop";
    inherit (unwrapped) version;
    strictDeps = true;
    __structuredAttrs = true;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p "$out/bin" "$out/share"
      ln -s ${fhsEnv}/bin/claude-desktop-fhsenv "$out/bin/claude-desktop"
      ln -s ${fhsEnv}/share/* "$out/share/"
    '';

    inherit (unwrapped) meta;
    passthru = unwrapped.passthru or {} // {inherit unwrapped fhsEnv;};
  }
