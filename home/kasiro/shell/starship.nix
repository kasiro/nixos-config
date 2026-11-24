{ ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = "$all$nix_shell$python\n$directory$git_branch$git_status\n$character";
      character = {
        error_symbol = "[❯](bold red)";
        success_symbol = "[❯](bold green)";
      };
      directory = {
        style = "bold cyan";
        truncation_length = 3;
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
        style = "bold purple";
      };
      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "bold red";
      };
      nix_shell = {
        format = "via [$symbol $name]($style) ";
        heuristic = true;
        impure_msg = "impure";
        pure_msg = "pure";
        style = "bold blue";
        symbol = "❄️";
        unknown_msg = "";
      };
    };
  };
}
