# Рабочие столы: фиксированное число + горячие клавиши Ctrl+1..0
{ ... }:
{
  dconf.settings = {
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 7;
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = [ "<Control>1" ];
      switch-to-workspace-2 = [ "<Control>2" ];
      switch-to-workspace-3 = [ "<Control>3" ];
      switch-to-workspace-4 = [ "<Control>4" ];
      switch-to-workspace-5 = [ "<Control>5" ];
      switch-to-workspace-6 = [ "<Control>6" ];
      switch-to-workspace-7 = [ "<Control>7" ];
      switch-to-workspace-8 = [ "<Control>8" ];
      switch-to-workspace-9 = [ "<Control>9" ];
      switch-to-workspace-10 = [ "<Control>0" ];
    };
  };
}
