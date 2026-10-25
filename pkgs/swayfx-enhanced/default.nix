{ stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wayland-scanner
, scdoc
, cairo
, gdk-pixbuf
, json-c
, libdrm
, libevdev
, libGL
, libinput
, librsvg
, libxkbcommon
, pango
, pcre2
, scenefx-enhanced
, wayland
, wayland-protocols
, wlroots_0_19
, xorg
, swaybg
}:

stdenv.mkDerivation {
  pname = "swayfx-enhanced";
  version = "0.5.3-enhanced.1";

  src = fetchFromGitHub {
    owner = "CreitinGameplays";
    repo = "swayfx-enhanced";
    rev = "21f81947114bd4c7bfb56bc7a870cd2c4263f635";
    hash = "sha256-1978hv94gxl95ls4kwgr9vsmaz1blbbdbyj1wxdy46p91mg5lmdx=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    scdoc
  ];

  buildInputs = [
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
    scenefx-enhanced
    wayland
    wayland-protocols
    wlroots_0_19
    xorg.xcbutilwm
  ];

  propagatedBuildInputs = [ swaybg ];

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
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.linux;
    mainProgram = "sway";

    longDescription = ''
      SwayFX Enhanced is a fork of SwayFX, which itself is a fork of the Sway
      Wayland compositor. This version adds Liquid Glass support and additional
      animations via the SceneFX Enhanced rendering pipeline.
    '';
  };
}
