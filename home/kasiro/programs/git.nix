{
  programs.git = {
    enable = true;
    settings = {
      user.name = "kasiro";
      user.email = "kon.konikov@mail.ru";
      push.autoSetupRemote = true;
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };
}
