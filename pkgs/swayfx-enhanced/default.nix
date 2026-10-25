{ stdenv
, lib
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wayland-scanner
, scdoc
  , cairo
  , gdk-pixbuf
  , json_c
  , libdrm
, libevdev
, libGL
, libinput
, librsvg
, libxkbcommon
, pango
  , pcre2
  , scenefx_enhanced
  , wayland
  , wayland-protocols
  , wlroots_0_19
, libxcb-wm
, swaybg
}:

stdenv.mkDerivation {
  pname = "swayfx-enhanced";
  version = "0.5.3-enhanced.1";

  src = fetchFromGitHub {
    owner = "CreitinGameplays";
    repo = "swayfx-enhanced";
    rev = "21f81947114bd4c7bfb56bc7a870cd2c4263f635";
    hash = "sha256-vVVaXg3pGuJb50H61daiK3xV9U758Uk0LYn2R9KG6KQ=";
  };

  strictDeps = true;

  # Как в nixpkgs sway-unwrapped: meson ищет scdoc через `dependency(native: true)`,
  # то есть build-машине нужен pkg-config в роли build-build, иначе .pc нативной
  # зависимости (scdoc) в PKG_CONFIG_PATH_FOR_BUILD не попадает в область видимости.
  depsBuildBuild = [ pkg-config ];

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
    json_c
    libdrm
    libevdev
    libGL
    libinput
    librsvg
    libxkbcommon
    pango
    pcre2
    scenefx_enhanced
    wayland
    wayland-protocols
    wlroots_0_19
    libxcb-wm
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

  # Апстримный sway.desktop содержит Exec=/usr/local/bin/sway-xwayland-session
  # (meson install_data копирует файл как есть). Заменяем точную строку:
  # убираем несуществующий /usr/local/bin (скрипт ставится в $out/bin и
  # находится через PATH) и добавляем --unsupported-gpu для NVIDIA.
  postInstall = ''
    substituteInPlace $out/share/wayland-sessions/sway.desktop \
      --replace-fail \
        'Exec=/usr/local/bin/sway-xwayland-session' \
        'Exec=sway-xwayland-session --unsupported-gpu'
  '';

  # Требуется модулем programs.sway: sessionPackages в display-manager
  # проверяет наличие passthru.providedSessions и файла <имя>.desktop
  passthru = {
    providedSessions = [ "sway" ];
  };

  meta = {
    description = "SwayFX Enhanced — Sway with Liquid Glass animations and effects";
    homepage = "https://github.com/CreitinGameplays/swayfx-enhanced";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "sway";

    longDescription = ''
      SwayFX Enhanced is a fork of SwayFX, which itself is a fork of the Sway
      Wayland compositor. This version adds Liquid Glass support and additional
      animations via the SceneFX Enhanced rendering pipeline.
    '';
  };
}
