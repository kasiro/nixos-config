{ stdenv
, lib
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wayland
, wlroots
, pango
  , cairo
  , gdk-pixbuf
  , json_c
  , libdrm
, libinput
, libGL
, libxkbcommon
, pcre2
, libevdev
}:

stdenv.mkDerivation {
  pname = "scenefx-enhanced";
  version = "0.4.1-enhanced";

  src = fetchFromGitHub {
    owner = "CreitinGameplays";
    repo = "scenefx-enhanced";
    rev = "33b6837";
    hash = "sha256-ELWBR77FQ198pSuOboNEFQEXgHwxVZ27gbsw1zWW/y0=";
  };

  nativeBuildInputs = [ meson ninja pkg-config ];
  buildInputs = [
    wayland
    wlroots
    pango
    cairo
    gdk-pixbuf
    json_c
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
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
