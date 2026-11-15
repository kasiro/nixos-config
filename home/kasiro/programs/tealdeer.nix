{
  programs.tealdeer = {
    enable = false;
    settings = {
      display = {
        compact = true; # Убирает лишние пустые строки
      };
      updates = {
        auto_update = true; # Сам обновляет базу примеров
      };
    };
  };
}