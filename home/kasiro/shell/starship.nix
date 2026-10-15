# Starship — промпт
{ ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = "$all$nix_shell$python\n$directory$git_branch$git_status\n$character";
      nix_shell = {
        heuristic = true;
        format = "via [$symbol $name]($style) ";
        symbol = "❄️";
        style = "bold blue";
        pure_msg = "pure";
        impure_msg = "impure";
        unknown_msg = "";
      };
      directory = {
        style = "bold cyan";
        truncation_length = 3;
      };
      git_branch = {
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };
      git_status = {
        style = "bold red";
        format = "[$all_status$ahead_behind]($style) ";
      };
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol   = "[❯](bold red)";
      };
    };
  };
}
