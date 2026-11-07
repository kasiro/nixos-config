{ inputs, pkgs, ... }:
{
  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;

    settings = {
      model = {
        default = "free-qwen3.5-plus";  # Рабочая модель из localproxy
        provider = "localproxy";
      };

      providers.localproxy = {
        base_url = "http://localhost:9625/v1";
        api_mode = "chat_completions";
      };

      environment.NO_PROXY = "localhost,127.0.0.1";
      environment.no_proxy = "localhost,127.0.0.1";

      timezone = "Asia/Novosibirsk";

      skills.external_dirs = [ "~/.agents/skills" ];

      agent = {
        max_turns = null;
        run_budget_seconds = 3600;
        coding_instructions = ''
          Отвечай по-русски. Не удаляй файлы без подтверждения.
        '';
        verify_on_stop = true;
      };

      compression = {
        enabled = true;
        threshold = 0.8;
        tail_mode = true;
      };

      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
        write_approval = false;
        memory_char_limit = 100000;
      };

      web = {
        backend = "";
        search_backend = "";
        cache_ttl_minutes = 30;
      };

      approvals = {
        mode = "smart";
        cron_mode = "deny";
        deny = [
          "rm -rf *"
          "git push --force*"
        ];
      };
    };

    extraPackages = with pkgs; [ ripgrep fd jq ];
  };
}
