{ inputs, pkgs, ... }:
{
  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;

    settings = {
      model = {
        default = "";            # id модели выберем позже (hermes model)
        provider = "localproxy"; # auto не увидит localproxy (детект только по env-ключам) — фиксируем провайдер явно
      };
      # Модели localproxy (9 шт.): free-gemini-2.5-pro, free-minimax-m2.7,
      # free-claude-haiku-4-5-20251001, free-gemini-2.5-flash, free-qwen3.5-plus,
      # free-qwen3.5-flash, free-minimax-m2.5, free-gemini-2.5-flash-lite,
      # free-gemini-3-flash-preview. Выбор: `hermes model`.

      # Локальный прокси-провайдер (перенесён из opencode.json)
      providers.localproxy = {
        base_url = "http://localhost:9625/v1";
        api_mode = "chat_completions";
        # discover_models = true;  # дефолт: список моделей берётся из /v1/models
        # key_env = "LOCALPROXY_API_KEY";  # раскомментировать, если прокси начнёт требовать ключ
      };

      # localhost-запросы не должны идти через HTTP_PROXY (урок 2026-09-17: httpx
      # не понимает CIDR в NO_PROXY — только точные адреса)
      environment.NO_PROXY = "localhost,127.0.0.1";
      environment.no_proxy = "localhost,127.0.0.1";

      # Часовой пояс агента
      timezone = "Asia/Novosibirsk";

      # Читать навыки из каталога OpenCode
      skills.external_dirs = [
        "~/.agents/skills"
      ];
    };

    # Инструменты на PATH агента (и у пользователя)
    extraPackages = with pkgs; [ ripgrep fd jq ];

    gateway.enable = true;  # шлюзы Telegram/Discord

    # API-ключи через environmentFiles (список путей-строк, НЕ path-литералов).
    # Файл создать вручную: chmod 600, формат KEY=value (по строке на переменную).
    # ВАЖНО: при каждом switch активация пересобирает ~/.hermes/.env с нуля.
    # environmentFiles = [ "/home/kasiro/.hermes/secrets.env" ];
  };

  # ─── На будущее: включать по одному блоку ─────────────────────────────

  ## Модель: фиксированный провайдер вместо auto.
  ## Anthropic (ключ в ANTHROPIC_API_KEY):
  # services.hermes-agent.settings.model = {
  #   default = "claude-sonnet-4-20250514";
  #   provider = "anthropic";
  # };
  ## OpenRouter (ключ в OPENROUTER_API_KEY):
  # services.hermes-agent.settings.model = {
  #   default = "anthropic/claude-sonnet-4";
  #   provider = "openrouter";
  # };
  ## base_url задавать не нужно — профили провайдеров сами знают эндпоинты.
  ## streaming / context_length трогать только при проблемах (обрывы стрима,
  ## обрезка контекста), не на всякий случай.

  ## Резервные провайдеры (fallback_providers): список, пробуются по порядку.
  ## Запись валидна ТОЛЬКО при наличии И provider, И model — иначе игнор.
  # services.hermes-agent.settings.fallback_providers = [
  #   { provider = "openrouter"; model = "deepseek/deepseek-chat"; }
  # ];

  ## Кастомные провайдеры (свои эндпоинты, OpenAI-совместимые прокси и т.п.).
  ## key_env — ИМЯ переменной окружения, не значение ключа!
  # services.hermes-agent.settings.providers = {
  #   my-proxy = {
  #     key_env = "MY_PROXY_API_KEY";
  #     api_mode = "chat";        # или "responses" — режим API эндпоинта
  #     # base_url = "https://...";  # при нестандартном эндпоинте
  #   };
  # };

  ## Поведение агента:
  services.hermes-agent.settings.agent = {
    max_turns = null;              # null = безлимит ходов
    run_budget_seconds = 3600;     # общий бюджет времени запуска
    # постоянные правила, добавляются к промпту
    coding_instructions = ''
      Отвечай по-русски. Не удаляй файлы без подтверждения.
    '';
    verify_on_stop = true;         # самопроверка перед остановкой
    # disabled_toolsets = [ ];       # имена наборов инструментов для отключения
  };

  ## Терминал агента:
  services.hermes-agent.settings.terminal = {
    backend = "local";             # local | docker | ...
    timeout = 120;                 # сек на команду
  };
  ## ВАЖНО: terminal.cwd НЕ задавать — модуль пишет его сам из workingDirectory.

  ## Сжатие контекста:
  services.hermes-agent.settings.compression = {
    enabled = true;
    threshold = 0.8;               # доля контекста, при которой жмём
    tail_mode = true;              # сохранять хвост диалога
    # per-model пороги (переопределяют общий):
    # per_model = { "anthropic/claude-sonnet-4" = 0.9; };
  };

  ## Память агента:
  services.hermes-agent.settings.memory = {
    memory_enabled = true;         # долговременная память
    user_profile_enabled = true;   # профиль пользователя
    write_approval = false;         # спрашивать подтверждение на запись
    memory_char_limit = 100000;    # лимит объёма памяти
  };

  ## Веб-инструменты:
  services.hermes-agent.settings.web = {
    backend = "";                  # пусто = keyless-ринг (без API-ключей)
    search_backend = "";           # бэкенд поиска
    cache_ttl_minutes = 30;        # кэш страниц
  };

  ## Подтверждения действий:
  services.hermes-agent.settings.approvals = {
    mode = "smart";                # smart = спрашивать только на опасное
    cron_mode = "deny";            # cron-задачи без подтверждений запрещены
    deny = [                       # глобы: блокируются даже под --yolo
      "rm -rf *"
      "git push --force*"
    ];
  };

  ## Шлюзы (gateway): Telegram/Discord — для будущего.
  # services.hermes-agent.settings.gateway = {
  #   telegram = {
  #     enabled = true;
  #     # streaming = true;           # стриминг ответов в чат
  #   };
  # };

  ## MCP-серверы (мержатся в settings.mcp_servers).
  ## Руками settings.mcp_servers НЕ задавать — только через этот блок.
  # services.hermes-agent.settings.mcpServers = {
  #   fs = {                         # stdio-сервер: локальный процесс
  #     command = "mcp-server-filesystem";
  #     args = [ "/home/kasiro" ];
  #   };
  #   remote = {                     # HTTP-сервер: удалённый эндпоинт
  #     url = "https://example.com/mcp";
  #     headers = { Authorization = "Bearer ..."; };
  #     timeout = 30;
  #   };
  # };

  ## Файлы в $HERMES_HOME (например, SOUL.md — системный промпт-личность):
  # services.hermes-agent.hermesHomeFiles = {
  #   "SOUL.md" = ''
  #     Ты — Hermes, ассистент сэра. Отвечай кратко и по делу.
  #   '';
  # };
  ## documents — файлы в рабочую директорию агента
  ## (требует явно заданного workingDirectory):
  # services.hermes-agent.documents = {
  #   "NOTES.md" = ''
  #     Рабочие заметки агента.
  #   '';
  # };

  ## НЕ задавать вручную:
  ## - terminal.cwd (пишется модулем из workingDirectory)
  ## - _config_version (служебное)
  ## - settings.mcp_servers (только через settings.mcpServers)
}
