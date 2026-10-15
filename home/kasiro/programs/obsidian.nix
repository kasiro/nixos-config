{ ... }: {
  xdg.desktopEntries.obsidian = {
    name        = "Obsidian";
    comment     = "Knowledge base";
    exec        = "obsidian %u";
    icon        = "obsidian";
    terminal    = false;
    categories  = [ "Office" ];
    mimeType    = [ "x-scheme-handler/obsidian" ];
    settings = {
      StartupWMClass = "md.obsidian.Obsidian";
      StartupNotify  = "true";
    };
  };
}
