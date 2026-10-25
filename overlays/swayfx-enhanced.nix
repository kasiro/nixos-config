# Оверлей для swayfx-enhanced — форк swayfx с Liquid Glass анимациями
# Репозиторий: https://github.com/CreitinGameplays/swayfx-enhanced
# Версия: 0.5.3-enhanced.1 (main branch, commit 21f8194)
{ prev }:

let
  # scenefx-enhanced — форк scenefx с Liquid Glass поддержкой
  scenefx-enhanced = prev.stdenv.mkDerivation {
    pname = "scenefx-enhanced";
    version = "0.4.1-enhanced";

    src = prev.fetchFromGitHub {
      owner = "CreitinGameplays";
      repo = "scenefx-enhanced";
      rev = "33b6837";
      hash = "sha256-0bgzjqsxfc5vh6xrsm9igj01f08m8j1nx3iblmy5yhy5pr3q3d8h=";
    };

    nativeBuildInputs = with prev; [ meson ninja pkg-config ];

    buildInputs = with prev; [
      wayland
      wlroots
      pango
      cairo
      gdk-pixbuf
      json-c
      libdrm
      libinput
      libGL
      libxkbcommon
      pcre2
      libevdev
    ];

    meta = {
      description = "SceneFX Enhanced — drop-in replacement for wlroots scene API with Liquid Glass effects";
      homepage = "https://github.com/CreitinGameplays/scenefx-enhanced";
      license = prev.lib.licenses.mit;
      platforms = prev.lib.platforms.linux;
    };
  };

in
{
  # swayfx-enhanced — основной пакет
  swayfx-enhanced = prev.stdenv.mkDerivation {
    pname = "swayfx-enhanced";
    version = "0.5.3-enhanced.1";

    src = prev.fetchFromGitHub {
      owner = "CreitinGameplays";
      repo = "swayfx-enhanced";
      rev = "21f81947114bd4c7bfb56bc7a870cd2c4263f635";
      hash = "sha256-1978hv94gxl95ls4kwgr9vsmaz1blbbdbyj1wxdy46p91mg5lmdx=";
    };

    strictDeps = true;

    nativeBuildInputs = with prev; [
      meson
      ninja
      pkg-config
      wayland-scanner
      scdoc
    ];

    buildInputs = with prev; [
      cairo
      gdk-pixbuf
      json-c
      libdrm
      libevdev
      libGL
      libinput
      librsvg
      libxkbcommon
      pango
      pcre2
      scenefx-enhanced  # Используем форк scenefx-enhanced
      wayland
      wayland-protocols
      wlroots_0_19
      xorg.xcbutilwm
    ];

    propagatedBuildInputs = with prev; [ swaybg ];

    mesonFlags = [
      "-Dsd-bus-provider=libsystemd"
      "-Dtray=enabled"
      "-Dgdk-pixbuf=enabled"
      "-Dman-pages=auto"
      "-Ddefault-wallpaper=true"
      "-Dswaybar=true"
      "-Dswaynag=true"
    ];

    postInstall = ''
      substituteInPlace $out/share/wayland-sessions/sway.desktop \
        --replace-fail 'Exec=sway' 'Exec=sway --unsupported-gpu'
    '';

    meta = {
      description = "SwayFX Enhanced — Sway with Liquid Glass animations and effects";
      homepage = "https://github.com/CreitinGameplays/swayfx-enhanced";
      license = prev.lib.licenses.mit;
      platforms = prev.lib.platforms.linux;
      mainProgram = "sway";

      longDescription = ''
        SwayFX Enhanced is a fork of SwayFX, which itself is a fork of the Sway
        Wayland compositor. This version adds Liquid Glass support and additional
        animations via the SceneFX Enhanced rendering pipeline.
      '';
    };
  };

  # Экспортируем scenefx-enhanced для других пакетов
  inherit scenefx-enhanced;
}
