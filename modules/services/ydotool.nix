# ydotool — эмуляция ввода (нужна группа uinput)
{ ... }:
{
  programs.ydotool.enable = true;
  programs.ydotool.group = "uinput";

  users.groups.uinput = { };
}
