/* ============================================================
 *  THEMES
 * ============================================================ */
const THEMES_DATA = {
  main: {
    avatar:      'https://mirai.senkuro.net/collectibles/188/a1ced692d1d6867fa586d198e317d7daeb70a8ff.webp',
    avatarFrame: 'https://mirai.senkuro.net/collectibles/379/4b14b05c6a5bbd2dedac114a527001ffef2fd9ad.webp',
    banner:      'https://mirai.senkuro.net/collectibles/41/58dfe0c91fd90edf2ae193cd84de1b7f69950273_1920.webm',
    wallpaper:   'https://mirai.senkuro.net/collectibles/56/023237e6c293d942cec4a8de2261f809bbd686a9_1920.webm',
  },
  shrek: {
    avatar:      'https://mirai.senkuro.net/collectibles/188/a1ced692d1d6867fa586d198e317d7daeb70a8ff.webp',
    avatarFrame: 'https://mirai.senkuro.net/collectibles/399/8af1120d3999d3208acd60c8c35cff2cbbab1a93.webp',
    banner:      'https://mirai.senkuro.net/collectibles/354/e5daf506564fe845d7cb1d6902e0891357ba4c35.jpeg',
    wallpaper:   'https://mirai.senkuro.net/collectibles/279/420d51c41e20b869ee0fb7eb13cc082fbc4c13c1_1920.webm',
  },
  cute_violet: {
    avatar:      'https://mirai.senkuro.net/collectibles/228/d9063d41879066f69066b7e3912d97b8df78384f.webp',
    avatarFrame: 'https://mirai.senkuro.net/collectibles/411/5b3eeb6cac4de2e462c27c9042dc4fc33a250d11.webp',
    banner:      'https://mirai.senkuro.net/collectibles/353/e75d9d6492dda57839e7f1e81c15f3cdf0ba476c.jpeg',
    wallpaper:   'https://mirai.senkuro.net/collectibles/290/29d778ff773cd9d6072144a8f9500f63133cf545_1920.webm',
  },
  spiderman: {
    avatar:      'https://mirai.senkuro.net/collectibles/327/f8508b64f54835a7abdbd4730e466a3d59898f1e.jpeg',
    avatarFrame: 'https://mirai.senkuro.net/collectibles/319/d9bc002cdb8a574f23b066755fab404032e2726a.webp',
    banner:      'https://mirai.senkuro.net/collectibles/299/256a4b7a95e2601d55021fbb9817801620d33af2_1920.webm',
    wallpaper:   'https://mirai.senkuro.net/collectibles/280/c363fa90dd0cb6eed7806124b3ab4bc3d46a6c6c_1920.webm',
  },
  red: {
    avatar:      'https://mirai.senkuro.net/collectibles/185/feeb08d3018478556b351e0703e5a4d60dabe34b.webp',
    avatarFrame: 'https://mirai.senkuro.net/collectibles/253/2efd80f4c4d0f0371d9480b66e1e2b7316d0f215.webp',
    banner:      'https://mirai.senkuro.net/collectibles/356/3a2ee310220b521168e92e0fd5936c716255efb3.jpeg',
    wallpaper:   'https://mirai.senkuro.net/collectibles/134/d7a0ca045556e10bc17af3aa758e36c4d63ba372.jpeg',
  },
  neon: {
    avatar:      'https://mirai.senkuro.net/collectibles/228/d9063d41879066f69066b7e3912d97b8df78384f.webp',
    avatarFrame: 'https://mirai.senkuro.net/collectibles/247/c641a61d87dd84cdeeced56708c0fd12d13eb034.webp',
    banner:      'https://mirai.senkuro.net/collectibles/67/0d65707807cc90c3cc3ef093dcf56df4c88c7068_1920.webm',
    wallpaper:   'https://mirai.senkuro.net/collectibles/2/4e25fec55be964d04633e724db6bb317cefc2c1b_1920.webm',
  },
  white: {
    avatar:      'https://mirai.senkuro.net/collectibles/188/a1ced692d1d6867fa586d198e317d7daeb70a8ff.webp',
    avatarFrame: 'https://mirai.senkuro.net/collectibles/96/05c78024f1d1d28d9f57160baaadcd0deb90b08b.webp',
    banner:      'https://mirai.senkuro.net/collectibles/351/c8bca7aaa99b514bbc86423708a9d9c6113b5d24.jpeg',
    wallpaper:   'https://mirai.senkuro.net/collectibles/64/79e730b65d617b74722ce0d52189523eebb2fc72_1920.webm',
  },
};

/* ============================================================
 *  FRAMEWORK
 * ============================================================ */
const Fw = (() => {
  const PARTS = ['avatar', 'avatarFrame', 'banner', 'wallpaper'];
  const PRESETS = {
    all:      PARTS.slice(),
    profile:  PARTS.slice(),
    cosmetic: ['avatar', 'avatarFrame'],
    none:     [],
  };

  const state = {
    selfHandle: null,
    themes:     {},
    rules:      new Map(),                       // handle -> { theme, parts }
    globalParts: PARTS.slice(),                  // что применять на не-профильных
    selectors: {
      profileAvatarLink: '.client-panel__avatar',   // <a> с аватаром в шапке профиля
      banner:            'img[alt$="\'s banner"]',
      wallpaper:         'video.wallpaper-wrapper-media',
    },
  };

  /* ---------- утилиты ---------- */
  const isVideo = (u) => /\.(webm|mp4|mov|m4v|ogv)(\?.*)?$/i.test(u);
  const isImage = (u) => {
    if (!u || isVideo(u)) return false;
    return /\.(jpe?g|png|webp|gif|avif|bmp|svg)(\?.*)?$/i.test(u)
        || !/\.\w{2,5}(\?.*)?$/i.test(u);
  };
  const setVar = (n, u) => document.documentElement.style.setProperty(`--${n}`, `url("${u}")`);
  const delVar = (n) => document.documentElement.style.removeProperty(`--${n}`);

  /* ============================================================
   *  БАННЕР — image через content: var(--banner); video — DOM-своп
   * ============================================================ */
  function applyBanner(url) {
    if (!url) return clearBanner();
    if (isImage(url)) {
      restoreBannerVideo();
      setVar('banner', url);
    } else if (isVideo(url)) {
      delVar('banner');
      swapBannerToVideo(url);
    }
  }

  function clearBanner() {
    delVar('banner');
    restoreBannerVideo();
  }

  function swapBannerToVideo(url) {
    const existing = document.querySelector('video[data-fw-banner-src]');
    if (existing) {
      if (existing.dataset.fwBannerSrc !== url) {
        existing.dataset.fwBannerSrc = url;
        existing.src = url;
        existing.load();
        existing.play().catch(() => {});
      }
      return;
    }
    const img = document.querySelector(state.selectors.banner);
    if (!img || img.tagName !== 'IMG') return;

    const v = document.createElement('video');
    Object.assign(v, { autoplay: true, loop: true, muted: true, playsInline: true, preload: 'auto' });
    v.setAttribute('muted', ''); v.setAttribute('playsinline', '');
    if (img.className) v.className = img.className;
    if (img.id) v.id = img.id;
    if (img.getAttribute('style')) v.setAttribute('style', img.getAttribute('style'));
    v.src = url;
    v.dataset.fwBannerSrc   = url;
    v.dataset.fwBannerAlt   = img.alt || '';
    v.dataset.fwBannerOrig  = img.src || '';

    img.replaceWith(v);
    v.play().catch(() => {});
  }

  function restoreBannerVideo() {
    const v = document.querySelector('video[data-fw-banner-src]');
    if (!v) return;
    const img = document.createElement('img');
    img.alt = v.dataset.fwBannerAlt || '';
    if (v.dataset.fwBannerOrig) img.src = v.dataset.fwBannerOrig;
    img.className = v.className;
    if (v.getAttribute('style')) img.setAttribute('style', v.getAttribute('style'));
    v.replaceWith(img);
  }

  /* ============================================================
   *  ОБОИ — image через background: var(--wallpaper); video — DOM-своп
   * ============================================================ */
  function applyWallpaper(url) {
    if (!url) return clearWallpaper();
    if (isImage(url)) {
      restoreWallpaperVideo();
      document.documentElement.dataset.wallpaperKind = 'image';
      setVar('wallpaper', url);
    } else if (isVideo(url)) {
      document.documentElement.removeAttribute('data-wallpaper-kind');
      delVar('wallpaper');
      swapWallpaperToVideo(url);
    }
  }

  function clearWallpaper() {
    delVar('wallpaper');
    document.documentElement.removeAttribute('data-wallpaper-kind');
    restoreWallpaperVideo();
  }

  function swapWallpaperToVideo(url) {
    const v = document.querySelector(state.selectors.wallpaper);
    if (!v || v.dataset.fwWpSrc === url) return;
    if (!v.dataset.fwWpOrig) {
      v.dataset.fwWpOrig = v.querySelector('source')?.src || v.src || '';
    }
    v.dataset.fwWpSrc = url;
    v.pause();
    v.querySelectorAll('source').forEach(s => s.remove());
    v.removeAttribute('src');
    const s = document.createElement('source');
    s.src = url;
    s.type = url.endsWith('.mp4') ? 'video/mp4' : 'video/webm';
    v.appendChild(s);
    v.load();
    v.play().catch(() => {});
  }

  function restoreWallpaperVideo() {
    const v = document.querySelector('video[data-fw-wp-src]');
    if (!v) return;
    const orig = v.dataset.fwWpOrig;
    delete v.dataset.fwWpSrc;
    delete v.dataset.fwWpOrig;
    if (!orig) return;
    v.pause();
    v.querySelectorAll('source').forEach(s => s.remove());
    v.removeAttribute('src');
    const s = document.createElement('source');
    s.src = orig;
    v.appendChild(s);
    v.load();
    v.play().catch(() => {});
  }

  /* ============================================================
   *  ПРОФИЛЬ — ищем .client-panel__avatar и его содержимое
   * ============================================================ */
  function findProfileAvatar() {
    const link = document.querySelector(state.selectors.profileAvatarLink);
    if (!link) return null;
    const avatar = link.querySelector('.avatar');
    if (!avatar) return null;
    return {
      link,
      avatar,
      frame:     avatar.querySelector('.avatar-frame img[alt="avatar frame"]'),
      imgAvatar: avatar.querySelector('.avatar-pic img:not([alt="avatar frame"])'),
      wrapper:   avatar.querySelector('.avatar-wrapper'),
    };
  }

  function unmarkProfile() {
    document.querySelectorAll(
      '[data-fw-profile],[data-fw-avatar],[data-fw-avatar-bg],[data-fw-frame]'
    ).forEach(el => {
      el.removeAttribute('data-fw-profile');
      el.removeAttribute('data-fw-avatar');
      el.removeAttribute('data-fw-avatar-bg');
      el.removeAttribute('data-fw-frame');
    });
    delVar('user-avatar');
    delVar('user-frame');
  }

  function markProfile(theme, parts) {
    // сброс всех маркеров профиля
    unmarkProfile();

    const ctx = getContext();
    if (!theme || (ctx.kind !== 'user' && ctx.kind !== 'self')) return;

    const found = findProfileAvatar();
    if (!found) return;

    const { link, frame, imgAvatar, wrapper } = found;
    link.setAttribute('data-fw-profile', '');

    // аватар
    if (parts.includes('avatar') && theme.avatar) {
      setVar('user-avatar', theme.avatar);
      if (imgAvatar)    imgAvatar.setAttribute('data-fw-avatar', '');
      else if (wrapper) wrapper.setAttribute('data-fw-avatar-bg', '');
    }

    // рамка
    if (parts.includes('avatarFrame') && theme.avatarFrame) {
      setVar('user-frame', theme.avatarFrame);
      if (frame) frame.setAttribute('data-fw-frame', '');
    }

    // баннер-картинка (видео свапается через applyBanner)
    if (parts.includes('banner') && theme.banner && isImage(theme.banner)) {
      const img = document.querySelector(state.selectors.banner);
      if (img && img.tagName === 'IMG') img.setAttribute('data-fw-banner', '');
    }
  }

  /* ============================================================
   *  КОНТЕКСТ И ПРАВИЛА
   * ============================================================ */
  function getContext() {
    const m = location.pathname.match(/^\/users\/@?([^/?#]+)/);
    if (!m) return { kind: 'page' };
    const handle = decodeURIComponent(m[1]);
    if (state.selfHandle && handle === state.selfHandle) return { kind: 'self', handle };
    return { kind: 'user', handle };
  }

  function resolveParts(spec, theme) {
    if (!theme) return [];
    if (spec == null) spec = 'all';
    const list = typeof spec === 'string'
      ? (PRESETS[spec] ?? [spec])
      : Array.isArray(spec) ? spec : [];
    return list.filter(p => theme[p]);
  }

  /* ============================================================
   *  ГЛАВНОЕ ПРИМЕНЕНИЕ
   * ============================================================ */
  function applyCurrent() {
    const ctx = getContext();
    const selfRule  = state.rules.get(state.selfHandle);
    const selfTheme = selfRule && state.themes[selfRule.theme];

    // 1) Своя мини-аватарка в навбаре — везде
    if (selfTheme) {
      if (selfTheme.avatar)      setVar('avatar', selfTheme.avatar);
      if (selfTheme.avatarFrame) setVar('avatar-frame', selfTheme.avatarFrame);
    }

    // 2) Тема для текущей страницы
    let pageTheme = null;
    let pageParts = [];

    if (ctx.kind === 'page') {
      pageTheme = selfTheme;
      pageParts = selfTheme ? state.globalParts.filter(p => selfTheme[p]) : [];
    } else if (ctx.kind === 'self') {
      pageTheme = selfTheme;
      pageParts = selfTheme ? resolveParts(selfRule.parts, selfTheme) : [];
    } else {
      const rule = state.rules.get(ctx.handle);
      pageTheme = rule && state.themes[rule.theme];
      pageParts = pageTheme ? resolveParts(rule.parts, pageTheme) : [];
    }

    // 3) Баннер и обои
    applyBanner(pageParts.includes('banner') && pageTheme?.banner ? pageTheme.banner : null);
    applyWallpaper(pageParts.includes('wallpaper') && pageTheme?.wallpaper ? pageTheme.wallpaper : null);

    // 4) Маркеры профиля
    if (ctx.kind === 'self' || ctx.kind === 'user') {
      markProfile(pageTheme, pageParts);
    } else {
      unmarkProfile();
    }
  }

  /* ============================================================
   *  РЕАКТИВНОСТЬ
   * ============================================================ */
  let lastUrl = location.href;
  let rafId = 0;

  function scheduleApply() {
    if (rafId) return;
    rafId = requestAnimationFrame(() => { rafId = 0; applyCurrent(); });
  }

  function onMaybeNavigate() {
    if (location.href !== lastUrl) {
      lastUrl = location.href;
      scheduleApply();
    }
  }

  // Navigation API — pushState / back / forward в современных SPA
  if (globalThis.navigation?.addEventListener) {
    navigation.addEventListener('navigatesuccess', () => {
      lastUrl = location.href;
      scheduleApply();
    });
  }
  window.addEventListener('popstate', onMaybeNavigate);

  // DOM-мутации — перерисовки SPA + смена URL вместе с ними
  const obs = new MutationObserver(() => {
    onMaybeNavigate();
    scheduleApply();
  });
  const startObs = () => obs.observe(document.body, { childList: true, subtree: true });
  if (document.body) startObs();
  else document.addEventListener('DOMContentLoaded', startObs, { once: true });

  // Страховка: раз в секунду проверяем URL (для навигаций без DOM-мутаций)
  setInterval(onMaybeNavigate, 1000);

  scheduleApply();

  /* ============================================================
   *  ПУБЛИЧНОЕ API
   * ============================================================ */
  return {
    /* темы */
    addTheme(name, data) { state.themes[name] = data; scheduleApply(); return this; },
    registerThemes(map)  { Object.assign(state.themes, map); scheduleApply(); return this; },
    removeTheme(name)    { delete state.themes[name]; scheduleApply(); return this; },

    /* кто я */
    setSelf(handle) { state.selfHandle = handle; scheduleApply(); return this; },

    /* своя тема */
    selfTheme(name, parts = 'all') {
      if (!state.selfHandle) { console.warn('[fw] setSelf first'); return this; }
      state.rules.set(state.selfHandle, { theme: name, parts });
      scheduleApply();
      return this;
    },

    /* правила для других */
    rule(handle, themeName, parts = 'all') {
      if (themeName == null) state.rules.delete(handle);
      else state.rules.set(handle, { theme: themeName, parts });
      scheduleApply();
      return this;
    },
    removeRule(handle) { state.rules.delete(handle); scheduleApply(); return this; },

    /* что применять на не-профильных страницах */
    globalParts(parts) { state.globalParts = parts; scheduleApply(); return this; },

    /* селекторы */
    selectors(sel) { Object.assign(state.selectors, sel); scheduleApply(); return this; },

    /* ручное применение */
    apply: applyCurrent,

    /* полный сброс всего, что мы навесили */
    reset() {
      delVar('avatar'); delVar('avatar-frame');
      clearBanner(); clearWallpaper(); unmarkProfile();
    },

    /* диагностика */
    getContext,
    inspect: () => ({
      selfHandle: state.selfHandle,
      themeNames: Object.keys(state.themes),
      rules: [...state.rules.entries()].map(([h, r]) => ({ handle: h, ...r })),
      globalParts: state.globalParts,
      context: getContext(),
      markers: {
        profile:  document.querySelectorAll('[data-fw-profile]').length,
        avatar:   document.querySelectorAll('[data-fw-avatar]').length,
        avatarBg: document.querySelectorAll('[data-fw-avatar-bg]').length,
        frame:    document.querySelectorAll('[data-fw-frame]').length,
        banner:   document.querySelectorAll('[data-fw-banner]').length,
      },
      vars: {
        avatar:     getComputedStyle(document.documentElement).getPropertyValue('--avatar').slice(0, 40),
        avatarFrame:getComputedStyle(document.documentElement).getPropertyValue('--avatar-frame').slice(0, 40),
        banner:     getComputedStyle(document.documentElement).getPropertyValue('--banner').slice(0, 40),
        wallpaper:  getComputedStyle(document.documentElement).getPropertyValue('--wallpaper').slice(0, 40),
        userAvatar: getComputedStyle(document.documentElement).getPropertyValue('--user-avatar').slice(0, 40),
        userFrame:  getComputedStyle(document.documentElement).getPropertyValue('--user-frame').slice(0, 40),
      },
    }),
    diagnose() {
      const found = findProfileAvatar();
      return {
        ctx: getContext(),
        found: {
          link:      !!found,
          frame:     !!found?.frame,
          imgAvatar: !!found?.imgAvatar,
          wrapper:   !!found?.wrapper,
        },
        markers: {
          profile:  document.querySelectorAll('[data-fw-profile]').length,
          avatar:   document.querySelectorAll('[data-fw-avatar]').length,
          avatarBg: document.querySelectorAll('[data-fw-avatar-bg]').length,
          frame:    document.querySelectorAll('[data-fw-frame]').length,
        },
      };
    },
  };
})();

/* ============================================================
 *  BOOTSTRAP
 * ============================================================ */
Fw
  .registerThemes(THEMES_DATA)
  .setSelf('192400650171074054')
  .selfTheme('main', 'all')
  .globalParts(['avatar', 'avatarFrame', 'banner', 'wallpaper'])
  .rule('107917975960445339', 'shrek', 'cosmetic');
