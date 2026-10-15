{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "lantern";
  version = "10.0.0";

  src = pkgs.fetchurl {
    url = "https://github.com/getlantern/lantern/releases/download/v${version}/lantern-installer.deb";
    hash = "sha256-xzZRdiz2dctWP29cFniCESAu3lvKfiRKepUzd0+P/Ck=";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  # Здесь перечисляем только те библиотеки, которые нужно
  # прописать в RPATH бинарников Electron. autoPatchelfHook
  # сам найдёт их через `ldd` и подставит в RUNPATH.
  buildInputs = with pkgs; [
    # --- базовые ---
    zlib
    glib
    gtk3
    gdk-pixbuf
    nss
    nspr
    atk
    at-spi2-atk
    cups
    dbus
    libdrm
    libxkbcommon
    mesa
    udev
    alsa-lib

    # --- шрифты / рендеринг ---
    fontconfig
    freetype
    harfbuzz
    expat
    pango
    cairo

    # --- X11 ---
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libXScrnSaver
    libxshmfence

    # --- OpenGL / GBM ---
    libGL
    libglvnd

    # --- misc ---
    util-linux        # libuuid
    libsecret
    openssl
    curl

    # --- WebKit для плагина desktop_webview_window ---
    webkitgtk_4_1          # libwebkit2gtk-4.1.so.0, libjavascriptcoregtk-4.1.so.0
    libsoup_3              # libsoup-3.0.so.0

    # --- Трей (libtray_manager_plugin) ---
    libayatana-appindicator # libayatana-appindicator3.so.1,
                            # libayatana-indicator3.so.7,
                            # libayatana-ido3-0.4.so.0
    libdbusmenu             # libdbusmenu-glib.so.4
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libjvm.so"
  ];
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    dpkg -x $src .

    # Копируем содержимое usr/ и opt/ в корень $out
    [ -d usr ] && cp -r usr/* $out/ || true
    [ -d opt ] && cp -r opt/* $out/ || true

    # Иногда бинарник лежит в /opt/Lantern/lantern, иногда —
    # в /usr/bin/lantern. Делаем симлинк в $out/bin для удобства.
    rm -f $out/bin/lantern
    mkdir -p $out/bin
    ln -sf $out/lib/lantern/lantern $out/bin/lantern

    # Некоторые .deb содержат свои .so внутри пакета —
    # autoPatchelfHook их тоже подхватит, если они попадут в $out.
    runHook postInstall
  '';

  # Chromium иногда тащит за собой бинарники без бита x —
  # autoPatchelfHook пройдёт по всем ELF, но с ограничениями.
  # При необходимости можно разрешить игнорировать ошибки:
  # autoPatchelfIgnoreMissingDeps = true;

  meta = {
    description = "Lantern proxy client";
    homepage = "https://github.com/getlantern/lantern";
    platforms = [ "x86_64-linux" ];
    mainProgram = "lantern";
  };
}
