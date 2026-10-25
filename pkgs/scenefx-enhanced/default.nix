{ stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wayland
, wlroots
, pango
  , cairo
  , gdk_pixbuf
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
    hash = "sha256-0bgzjqsxfc5vh6xrsm9igj01f08m8j1nx3iblmy5yhy5pr3q3d8h=";
  };

  nativeBuildInputs = [ meson ninja pkg-config ];
  buildInputs = [
    wayland
    wlroots
    pango
    cairo
    gdk_pixbuf
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
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.linux;
  };
}
