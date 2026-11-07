{
  programs.mpvpaper = {
    enable = true;
    # pauseList намеренно не задаём: он смотрит на pgrep, а не на видимость
    # обоев, и дрался бы за IPC с wallpaper-pause.sh
  };
}