{ ... }: {
  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./shell/fish/init.fish;
    interactiveShellInit = builtins.readFile ./shell/fish/interactive.fish;
  };
}
