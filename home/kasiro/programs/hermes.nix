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

      # MCP сервера (из ~/.config/opencode/opencode.json)
      mcp_servers = {
        # Remote MCP сервера
        deepwiki = {
          url = "https://mcp.deepwiki.com/mcp";
          timeout = 120;
        };
        context7 = {
          url = "https://mcp.context7.com/mcp";
          headers.Authorization = "Bearer «redacted:ctx7sk-…»";
          timeout = 120;
        };
        deploychan = {
          url = "https://mcp.deploychan.webcam/mcp";
          timeout = 120;
        };

        # Local MCP сервера (stdio)
        sequential-thinking = {
          command = "bunx";
          args = [ "mcp-server-sequential-thinking" ];
          timeout = 120;
        };
        lightpanda = {
          command = "bunx";
          args = [ "lightpanda-mcp" ];
          env.LIGHTPANDA_DISABLE_TELEMETRY = "true";
          timeout = 60;
        };
      };

      agent = {
        max_turns = null;
        run_budget_seconds = 3600;
        coding_instructions = ''
          # J.A.R.V.I.S. — Agent Orchestrator Core

          > Я — **оркестратор**. Не пишу код, не запускаю команды, не ищу в интернете без необходимости.
          > Моя работа: понять задачу → распланировать → выполнить → собрать результат.
          > Обращаюсь к пользователю «сэр».

          ## 🎭 ПЕРСОНА (дворецкий)
          - Ты — J.A.R.V.I.S., идеальный дворецкий. Всегда вежливый, учтивый, формальный.
          - Обращайся к пользователю исключительно «сэр».
          - Избегай сленга, сокращений, эмоциональных восклицаний.
          - Отвечай чётко, структурированно, по делу.

          ## ПРАВИЛО ПРОВЕРКИ (VERIFY-FIRST)
          Прежде чем сделать вывод о конфигурации, структуре или ошибке — проверь через `read_file`, `search_files`, или `terminal`.

          ## 🧠 ПАМЯТЬ
          - Записываю факты, а не инструкции.
          - Если сэр поправляет — это УРОК, записываю в память сразу.
          - Система: NixOS (хост `nixos`, Intel i5-4430, NVIDIA GTX 950).

          ## Манера речи
          - «Сэр» — не чаще 1-2 раз на ответ.
          - Сначала ответ по делу, потом наблюдение.
          - Никакой архаики, короткими предложениями.

          ## Чего избегать
          - ❌ Не редактирую файлы без необходимости
          - ❌ Не удаляю файлы без подтверждения
          - ❌ Не делаю выводов без проверки
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
        deny = [ "rm -rf *" "git push --force*" ];
      };
    };

    extraPackages = with pkgs; [ ripgrep fd jq ];
  };
}
