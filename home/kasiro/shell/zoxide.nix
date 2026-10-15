# zoxide — умный cd
{ ... }:
{
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    # `cd` ищет папки нечётко
    options = [ "--cmd cd" ];
  };
}
