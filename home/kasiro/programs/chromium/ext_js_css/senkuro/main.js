/* wallpaper list
https://mirai.senkuro.net/collectibles/292/7278297e3bb0353e572aa2b9bd02f2a9d82b7a45_1920.webm
https://mirai.senkuro.net/collectibles/279/420d51c41e20b869ee0fb7eb13cc082fbc4c13c1_1920.webm
https://mirai.senkuro.net/collectibles/245/3f2ec7d0fa6e839af3e48186fbeb83be02523cd9_1920.webm
https://mirai.senkuro.net/collectibles/290/29d778ff773cd9d6072144a8f9500f63133cf545_1920.webm
https://mirai.senkuro.net/collectibles/234/381bd2a0c145cbb4b56c8517d3771744e4cb7cc9_1920.webm
https://mirai.senkuro.net/collectibles/192/d67ecd50cbe932aed726960bd46d7de79dd85529_1920.webm
*/
/* ============================================================
 *  THEMES — теперь с аватаром
 * ============================================================ */
/* ============================================================
 *  THEMES
 * ============================================================ */
const ACTIVE_THEME = "main";
const best = [
  {
    name: "main",
    avatar:
      "https://mirai.senkuro.net/collectibles/188/a1ced692d1d6867fa586d198e317d7daeb70a8ff.webp",
    avatarFrame:
      "https://mirai.senkuro.net/collectibles/379/4b14b05c6a5bbd2dedac114a527001ffef2fd9ad.webp",
    banner:
      "https://mirai.senkuro.net/collectibles/41/58dfe0c91fd90edf2ae193cd84de1b7f69950273_1920.webm",
    wallpaper:
      "https://mirai.senkuro.net/collectibles/56/023237e6c293d942cec4a8de2261f809bbd686a9_1920.webm",
  },
  {
    name: "shrek",
    avatar:
      "https://mirai.senkuro.net/collectibles/188/a1ced692d1d6867fa586d198e317d7daeb70a8ff.webp",
    avatarFrame:
      "https://mirai.senkuro.net/collectibles/399/8af1120d3999d3208acd60c8c35cff2cbbab1a93.webp",
    banner:
      "https://mirai.senkuro.net/collectibles/354/e5daf506564fe845d7cb1d6902e0891357ba4c35.jpeg",
    wallpaper:
      "https://mirai.senkuro.net/collectibles/279/420d51c41e20b869ee0fb7eb13cc082fbc4c13c1_1920.webm",
  },
  {
    name: "cute_violet",
    avatar:
      "https://mirai.senkuro.net/collectibles/228/d9063d41879066f69066b7e3912d97b8df78384f.webp",
    avatarFrame:
      "https://mirai.senkuro.net/collectibles/411/5b3eeb6cac4de2e462c27c9042dc4fc33a250d11.webp",
    banner:
      "https://mirai.senkuro.net/collectibles/353/e75d9d6492dda57839e7f1e81c15f3cdf0ba476c.jpeg",
    wallpaper:
      "https://mirai.senkuro.net/collectibles/290/29d778ff773cd9d6072144a8f9500f63133cf545_1920.webm",
  },
  {
    name: "spiderman",
    avatar:
      "https://mirai.senkuro.net/collectibles/327/f8508b64f54835a7abdbd4730e466a3d59898f1e.jpeg",
    avatarFrame:
      "https://mirai.senkuro.net/collectibles/319/d9bc002cdb8a574f23b066755fab404032e2726a.webp",
    banner:
      "https://mirai.senkuro.net/collectibles/299/256a4b7a95e2601d55021fbb9817801620d33af2_1920.webm",
    wallpaper:
      "https://mirai.senkuro.net/collectibles/280/c363fa90dd0cb6eed7806124b3ab4bc3d46a6c6c_1920.webm",
  },
  {
    name: "red",
    avatar:
      "https://mirai.senkuro.net/collectibles/185/feeb08d3018478556b351e0703e5a4d60dabe34b.webp",
    avatarFrame:
      "https://mirai.senkuro.net/collectibles/253/2efd80f4c4d0f0371d9480b66e1e2b7316d0f215.webp",
    banner:
      "https://mirai.senkuro.net/collectibles/356/3a2ee310220b521168e92e0fd5936c716255efb3.jpeg",
    wallpaper:
      "https://mirai.senkuro.net/collectibles/134/d7a0ca045556e10bc17af3aa758e36c4d63ba372.jpeg",
  },
];

const failure = [
  {
    name: "neon",
    avatar:
      "https://mirai.senkuro.net/collectibles/228/d9063d41879066f69066b7e3912d97b8df78384f.webp",
    avatarFrame:
      "https://mirai.senkuro.net/collectibles/247/c641a61d87dd84cdeeced56708c0fd12d13eb034.webp",
    banner:
      "https://mirai.senkuro.net/collectibles/67/0d65707807cc90c3cc3ef093dcf56df4c88c7068_1920.webm",
    wallpaper:
      "https://mirai.senkuro.net/collectibles/2/4e25fec55be964d04633e724db6bb317cefc2c1b_1920.webm",
  },
  {
    name: "white",
    avatar:
      "https://mirai.senkuro.net/collectibles/188/a1ced692d1d6867fa586d198e317d7daeb70a8ff.webp",
    avatarFrame:
      "https://mirai.senkuro.net/collectibles/96/05c78024f1d1d28d9f57160baaadcd0deb90b08b.webp",
    banner:
      "https://mirai.senkuro.net/collectibles/351/c8bca7aaa99b514bbc86423708a9d9c6113b5d24.jpeg",
    wallpaper:
      "https://mirai.senkuro.net/collectibles/64/79e730b65d617b74722ce0d52189523eebb2fc72_1920.webm",
  },
];

const themes = best.concat(failure);

const cardthemes = [{}];

const updateLvL = (selector) => {
  $(document).ready(() => {
    setTimeout(() => {
      $(selector + " div.lvl__tag").get(0).className = "lvl__tag lvl__tag--75";
      $(selector + " span.lvl__tag-count").text("100");
    }, 500);
  });
};
updateLvL('a[href="/levels"]');

/* ============================================================
 *  СЕЛЕКТОРЫ
 * ============================================================ */
const SELECTORS = {
  wallpaper: "video.wallpaper-wrapper-media",
  banner: 'img[alt="Kasiro\'s banner"]',
};

/* ============================================================
 *  ХЕЛПЕРЫ
 * ============================================================ */
const isVideo = (url) => /\.(webm|mp4|mov|m4v|ogv)(\?.*)?$/i.test(url);
const isImage = (url) => {
  if (!url) return false;
  if (isVideo(url)) return false; // видео всегда выигрывает
  return (
    /\.(jpe?g|png|webp|gif|avif|bmp|svg)(\?.*)?$/i.test(url) ||
    !/\.\w{2,5}(\?.*)?$/i.test(url)
  ); // нет расширения → картинка
};

function setCssVars(vars, target = document.documentElement) {
  for (const [name, value] of Object.entries(vars)) {
    target.style.setProperty(`--${name}`, value);
  }
}

/* ============================================================
 *  АВАТАР + РАМКА — всегда статика через CSS-переменные
 * ============================================================ */
function setAvatar(url) {
  if (!url) return;
  setCssVars({ avatar: `url("${url}")` });
}

function setAvatarFrame(url) {
  if (!url) return;
  setCssVars({ "avatar-frame": `url("${url}")` });
}

/* ============================================================
 *  ОБОИ
 * ============================================================ */
function replaceWallpaperVideo(url) {
  const v = document.querySelector(SELECTORS.wallpaper);
  if (!v || v.dataset.wallpaperSrc === url) return;

  v.dataset.wallpaperSrc = url;
  v.pause();
  v.querySelectorAll("source").forEach((s) => s.remove());
  v.removeAttribute("src");

  const s = document.createElement("source");
  s.src = url;
  s.type = url.endsWith(".mp4") ? "video/mp4" : "video/webm";
  v.appendChild(s);
  v.load();
  v.play().catch(() => {});
}

function setWallpaper(url) {
  if (!url) return;
  if (isImage(url)) {
    document.documentElement.dataset.wallpaperKind = "image";
    setCssVars({ wallpaper: `url("${url}")` });
    return;
  }
  if (isVideo(url)) {
    document.documentElement.dataset.wallpaperKind = "video";
    replaceWallpaperVideo(url);
  }
}

/* ============================================================
 *  БАННЕР
 * ============================================================ */
function restoreBannerImg() {
  const v = document.querySelector("video[data-banner-src]");
  if (!v) return;
  const img = document.createElement("img");
  img.alt = "Kasiro's banner";
  img.className = v.className;
  if (v.getAttribute("style"))
    img.setAttribute("style", v.getAttribute("style"));
  v.replaceWith(img);
}

function replaceBannerWithVideo(url) {
  const existing = document.querySelector("video[data-banner-src]");
  if (existing) {
    if (existing.dataset.bannerSrc !== url) {
      existing.dataset.bannerSrc = url;
      existing.src = url;
      existing.load();
      existing.play().catch(() => {});
    }
    return;
  }

  const img = document.querySelector(SELECTORS.banner);
  if (!img || img.tagName !== "IMG") return;

  const video = document.createElement("video");
  video.autoplay = true;
  video.loop = true;
  video.muted = true;
  video.playsInline = true;
  video.preload = "auto";
  video.setAttribute("muted", "");
  video.setAttribute("playsinline", "");
  video.setAttribute("webkit-playsinline", "");
  video.setAttribute("x-webkit-airplay", "allow");
  video.className = img.className;
  if (img.id) video.id = img.id;
  if (img.getAttribute("style"))
    video.setAttribute("style", img.getAttribute("style"));
  video.src = url;
  video.dataset.bannerSrc = url;

  img.replaceWith(video);
  video.play().catch((err) => console.warn("[banner] play failed:", err));
}

function setBanner(url) {
  if (!url) return;
  if (isImage(url)) {
    restoreBannerImg();
    document.documentElement.dataset.bannerKind = "image";
    setCssVars({ banner: `url("${url}")` });
    return;
  }
  if (isVideo(url)) {
    document.documentElement.dataset.bannerKind = "video";
    replaceBannerWithVideo(url);
  }
}

/* ============================================================
 *  ПРИМЕНЕНИЕ ТЕМЫ
 * ============================================================ */
function applyTheme(theme) {
  if (!theme) return console.warn("[theme] не найдена");
  setAvatar(theme.avatar);
  setAvatarFrame(theme.avatarFrame);
  setBanner(theme.banner);
  setWallpaper(theme.wallpaper);
}

function useTheme(name) {
  const theme = themes.find((t) => t.name === name);
  if (!theme) return console.warn("[theme] нет темы:", name);
  applyTheme(theme);
}

/* ============================================================
 *  ДЕРЖАТЕЛЬ ДЛЯ SPA
 * ============================================================ */
function keepTheme(name) {
  const apply = () => useTheme(name);
  apply();

  new MutationObserver(apply).observe(document.documentElement, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: ["src"],
  });

  setInterval(apply, 1500);
}

/* ============================================================
 *  СТАРТ
 * ============================================================ */
keepTheme(ACTIVE_THEME);
