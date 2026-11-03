# Скрипты активации — инициализация проектов при первой установке
{ ... }:
{
  system.activationScripts.project-init.text = ''
    # kasiro проекты
    
    # kasiro-proxy
    if [ ! -d "/home/kasiro/Документы/kasiro-proxy" ]; then
      echo "==> [kasiro] kasiro-proxy: клонирую"
      rm -rf "/home/kasiro/Документы/kasiro-proxy"
      git clone "https://github.com/kasiro/proxy" "/home/kasiro/Документы/kasiro-proxy"
      chown -R kasiro:users "/home/kasiro/Документы/kasiro-proxy"
    else
      echo "==> [kasiro] kasiro-proxy: уже существует"
    fi

    # opencode
    if [ ! -d "/home/kasiro/.config/opencode" ]; then
      echo "==> [kasiro] opencode: клонирую"
      rm -rf "/home/kasiro/.config/opencode"
      git clone "https://github.com/kasiro/opencode-config" "/home/kasiro/.config/opencode"
      chown -R kasiro:users "/home/kasiro/.config/opencode"
    else
      echo "==> [kasiro] opencode: уже существует"
    fi

    # skills
    if [ ! -d "/home/kasiro/.agents/skills" ]; then
      echo "==> [kasiro] skills: клонирую"
      rm -rf "/home/kasiro/.agents/skills"
      git clone "https://github.com/kasiro/agents_skills_backup" "/home/kasiro/.agents/skills"
      chown -R kasiro:users "/home/kasiro/.agents/skills"
    else
      echo "==> [kasiro] skills: уже существует"
    fi

    # nvim
    if [ ! -d "/home/kasiro/.config/nvim" ]; then
      echo "==> [kasiro] nvim: клонирую"
      rm -rf "/home/kasiro/.config/nvim"
      git clone "https://github.com/kasiro/nvim_config" "/home/kasiro/.config/nvim"
      chown -R kasiro:users "/home/kasiro/.config/nvim"
    else
      echo "==> [kasiro] nvim: уже существует"
    fi

    # dl
    if [ ! -d "/home/kasiro/Документы/dl" ]; then
      echo "==> [kasiro] dl: клонирую"
      rm -rf "/home/kasiro/Документы/dl"
      git clone "https://github.com/kasiro/dl" "/home/kasiro/Документы/dl"
      chown -R kasiro:users "/home/kasiro/Документы/dl"
    else
      echo "==> [kasiro] dl: уже существует"
    fi

    # whitepeach проект (Marsel)
    if [ ! -d "/home/whitepeach/Документы/Marsel" ]; then
      echo "==> [whitepeach] Marsel: клонирую"
      rm -rf "/home/whitepeach/Документы/Marsel"
      git clone https://github.com/korneevnaanastasia-beep/Mars "/home/whitepeach/Документы/Marsel"
      chown -R whitepeach:users "/home/whitepeach/Документы/Marsel"
    else
      echo "==> [whitepeach] Marsel: уже существует"
    fi
  '';
}
