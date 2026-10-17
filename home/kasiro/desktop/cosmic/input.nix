{ ... }:
{
  xdg.configFile = {
    # Настройка XKB (раскладки и переключение)
    "cosmic/com.system76.CosmicComp/v1/xkb_config" = {
      text = ''
        (
            rules: "",
            model: "pc104",
            layout: "us,ru",
            variant: ",",
            options: Some("terminate:ctrl_alt_bksp,grp:shift_alt_toggle"),
            repeat_delay: 600,
            repeat_rate: 25,
        )
      '';
      force = true;
    };
    # Опционально: тема (тёмная)
    "cosmic/com.system76.CosmicTheme.Mode/v1/is_dark" = {
      text = "true";
      force = true;
    };
  };
}
