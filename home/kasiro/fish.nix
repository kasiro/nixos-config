{ ... }: {
  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./fish/init.fish;
    interactiveShellInit = builtins.readFile ./fish/interactive.fish;
  };
}
