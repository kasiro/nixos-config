{ inputs, ... }:
{
  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;
    # gateway.enable = true;  # шлюзы Telegram/Discord — пока не нужен
    # API-ключи потом через environmentFiles (список путей-строк, НЕ path-литералов):
    # environmentFiles = [ "/home/kasiro/.hermes/secrets.env" ];
  };
}
