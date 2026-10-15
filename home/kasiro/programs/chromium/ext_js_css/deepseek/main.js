// Посмотреть текущее значение
const currentLocale = JSON.parse(
  localStorage.getItem("__appKit_@deepseek/chat_localePreference"),
);
if (currentLocale.value !== "system") {
  // Установить русский и перезагрузить
  localStorage.setItem(
    "__appKit_@deepseek/chat_localePreference",
    JSON.stringify({ value: "system", __version: "0" }),
  );
  location.reload();
}
