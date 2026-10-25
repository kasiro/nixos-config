# Оверлей для swayfx-enhanced — форк swayfx с Liquid Glass анимациями
# Репозиторий: https://github.com/CreitinGameplays/swayfx-enhanced
# Версия: 0.5.3-enhanced.1 (main branch, commit 21f8194)
self: super: {
  scenefx-enhanced = self.callPackage ../pkgs/scenefx-enhanced {};
  swayfx-enhanced = self.callPackage ../pkgs/swayfx-enhanced {};
}
