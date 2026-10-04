(function () {
  const THEME_MARKER = "data-freedium-theme-applied";
  const COPY_BUTTON_SELECTOR =
    ".hljs-copy, button.code-copy-btn[data-code], button[aria-label='Copy code'][data-code]";
  const SHIKI_TOKEN_SELECTOR = "pre.shiki code span[style]";
  const CODE_WORK_SELECTOR =
    COPY_BUTTON_SELECTOR + ", " + SHIKI_TOKEN_SELECTOR;
  const SHIKI_ROLE_HEXES = {
    "on-surface": ["#24292e", "#e1e4e8"],
    "on-surface-variant": ["#6a737d", "#586069", "#d1d5da"],
    error: ["#d73a49", "#f97583", "#b31d28", "#fdaeb7"],
    primary: ["#032f62", "#9ecbff", "#dbedff"],
    tertiary: ["#6f42c1", "#b392f0", "#22863a", "#85e89d"],
    secondary: ["#005cc5", "#79b8ff", "#e36209", "#ffab70"],
  };
  const SHIKI_ROLE_VARS = {
    "on-surface": "--app-on-surface",
    "on-surface-variant": "--app-on-surface-variant",
    error: "--app-error",
    primary: "--app-primary",
    tertiary: "--app-tertiary",
    secondary: "--app-secondary",
  };
  const SHIKI_HEX_TO_VAR = {};
  Object.keys(SHIKI_ROLE_HEXES).forEach(function (role) {
    SHIKI_ROLE_HEXES[role].forEach(function (hex) {
      SHIKI_HEX_TO_VAR[hex] = "var(" + SHIKI_ROLE_VARS[role] + ")";
    });
  });

  if (document.documentElement.hasAttribute(THEME_MARKER)) {
    console.log("Freedium theme already applied, reapplying");
  }
  document.documentElement.setAttribute(THEME_MARKER, Date.now().toString());

  document
    .querySelectorAll("style[data-freedium-injected]")
    .forEach(function (el) {
      el.remove();
    });

  if (window._freediumCodeDomCleanup) {
    try {
      window._freediumCodeDomCleanup();
    } catch (e) {
      console.warn("Failed to clean up previous code observers:", e);
    }
  } else if (window._freediumCopyObserver) {
    try {
      window._freediumCopyObserver.disconnect();
      window._freediumCopyObserver = null;
    } catch (e) {
      console.warn("Failed to disconnect previous observer:", e);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", applyTheme, { once: true });
  } else {
    applyTheme();
  }

  function applyTheme() {
    try {
      const isDarkMode = "%IS_DARK_MODE%";
      const isDark = isDarkMode === "true";
      const showSitePopups = "%SHOW_SITE_POPUPS%" === "true";

      const styleSheet = document.createElement("style");
      styleSheet.setAttribute("data-freedium-injected", "vars");
      styleSheet.textContent = `%CSS_VARS%`;
      document.head.appendChild(styleSheet);

      setFreediumTheme(isDark);

      const customCSS = document.createElement("style");
      customCSS.setAttribute("data-freedium-injected", "custom");
      customCSS.textContent = `%CUSTOM_CSS_CONTENT%`;
      document.head.appendChild(customCSS);

      setSitePopupsVisibility(showSitePopups);
      syncLegacyHighlightTheme(isDark);
      lockNativeThemeControls(isDark);
      installCopyButtonOverrides();
      installReadingProgressTracking();
      notifyThemeApplied();

      setTimeout(extractArticleMeta, 800);
    } catch (e) {
      console.error("Theme application failed:", e);
      notifyThemeApplied();
    }
  }

  function setFreediumTheme(isDark) {
    const root = document.documentElement;
    const themeName = isDark ? "dark" : "light";

    if (isDark) {
      root.classList.add("dark");
      root.style.setProperty("--lightense-backdrop", "black", "important");
    } else {
      root.classList.remove("dark");
      root.style.setProperty("--lightense-backdrop", "white", "important");
    }

    root.style.colorScheme = themeName;
    root.setAttribute("data-freedium-app-theme", themeName);

    const freediumTokens = {
      "--bg": "var(--app-surface)",
      "--bg-2": "var(--app-surface-container-low)",
      "--bg-3": "var(--app-surface-container)",
      "--line": "var(--app-outline-variant)",
      "--line-2": "var(--app-outline)",
      "--ink": "var(--app-on-surface)",
      "--ink-2": "var(--app-on-surface-variant)",
      "--ink-3": "var(--app-on-surface-variant)",
      "--ink-4": "var(--app-outline)",
      "--accent": "var(--app-primary)",
      "--accent-deep": "var(--app-primary-container)",
      "--primary": "var(--app-primary)",
      "--primary-foreground": "var(--app-on-primary)",
      "--accent-foreground": "var(--app-on-primary)",
      "--muted": "var(--app-surface-variant)",
      "--muted-foreground": "var(--app-on-surface-variant)",
      "--card": "var(--app-surface)",
      "--card-foreground": "var(--app-on-surface)",
      "--popover": "var(--app-surface-container)",
      "--popover-foreground": "var(--app-on-surface)",
      "--border": "var(--app-outline-variant)",
      "--ring": "var(--app-primary)",
    };

    Object.keys(freediumTokens).forEach(function (key) {
      root.style.setProperty(key, freediumTokens[key], "important");
    });

    try {
      localStorage.setItem("theme", themeName);
      localStorage.setItem("mode-watcher-mode", themeName);
      localStorage.setItem("mode-watcher-theme", themeName);
    } catch (e) {
      console.warn("Failed to set localStorage theme:", e);
    }

    try {
      const themeMetaEl = document.querySelector('meta[name="theme-color"]');
      const surface = getComputedStyle(root)
        .getPropertyValue("--app-surface")
        .trim();
      if (themeMetaEl && surface) {
        themeMetaEl.setAttribute("content", surface);
      }
    } catch (e) {
      console.warn("Failed to update theme-color meta:", e);
    }
  }

  function setSitePopupsVisibility(show) {
    const root = document.documentElement;
    if (show) {
      root.removeAttribute("data-freedium-hide-site-popups");
    } else {
      root.setAttribute("data-freedium-hide-site-popups", "true");
    }
  }

  function syncLegacyHighlightTheme(isDark) {
    try {
      const desiredHljsTheme = isDark ? "github-dark" : "github";
      const hljsThemeUrl = `https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/${desiredHljsTheme}.min.css`;
      const links = Array.from(
        document.querySelectorAll('link[href*="highlight.js"][href*="styles"]')
      );

      links.forEach(function (link, index) {
        if (index === 0) {
          link.href = hljsThemeUrl;
          link.setAttribute("data-freedium-injected", "hljs-theme");
        } else {
          link.remove();
        }
      });
    } catch (e) {
      console.warn("Failed to set legacy HLJS theme:", e);
    }
  }

  function lockNativeThemeControls(isDark) {
    try {
      if (window.changeTheme) {
        window.changeTheme = function (themeName) {
          console.log(
            "Freedium App: Preventing web page theme change:",
            themeName
          );
          setFreediumTheme(isDark);
          return false;
        };
      }

      document
        .querySelectorAll("#darkModeToggle, .theme-toggle")
        .forEach(function (button) {
          button.setAttribute("aria-checked", isDark ? "true" : "false");
          button.setAttribute("tabindex", "-1");
          if (button.getAttribute("data-freedium-theme-locked") === "true") {
            return;
          }
          button.setAttribute("data-freedium-theme-locked", "true");
          button.addEventListener(
            "click",
            function (event) {
              event.preventDefault();
              event.stopImmediatePropagation();
              setFreediumTheme(isDark);
            },
            true
          );
        });
    } catch (e) {
      console.warn("Failed to lock native theme controls:", e);
    }
  }

  function installCopyButtonOverrides() {
    try {
      const pendingRoots = new Set();
      let scheduledFrame = null;
      let scheduledTimer = null;
      let cleanupTimer = null;

      function processCodeNode(node) {
        if (node.matches(COPY_BUTTON_SELECTOR)) {
          overrideCopyButton(node);
        } else {
          recolorShikiToken(node);
        }
      }

      function processCodeSubtree(root) {
        if (root.nodeType === 1 && root.matches(CODE_WORK_SELECTOR)) {
          processCodeNode(root);
        }

        root.querySelectorAll(CODE_WORK_SELECTOR).forEach(processCodeNode);
      }

      function flushPendingRoots() {
        scheduledFrame = null;
        scheduledTimer = null;

        const roots = Array.from(pendingRoots);
        pendingRoots.clear();
        const rootsInBatch = new Set(roots);
        roots.forEach(function (root) {
          let ancestor = root.parentNode;
          while (ancestor && ancestor !== document) {
            if (rootsInBatch.has(ancestor)) {
              return;
            }
            ancestor = ancestor.parentNode;
          }
          if (root.isConnected) {
            processCodeSubtree(root);
          }
        });
      }

      function schedulePendingRoots() {
        if (scheduledFrame !== null || scheduledTimer !== null) {
          return;
        }

        if (typeof window.requestAnimationFrame === "function") {
          scheduledFrame = window.requestAnimationFrame(flushPendingRoots);
        } else {
          scheduledTimer = setTimeout(flushPendingRoots, 16);
        }
      }

      function addPendingRoot(node) {
        pendingRoots.add(node);
      }

      function onMutations(mutations) {
        for (const mutation of mutations) {
          if (mutation.type === "attributes") {
            const target = mutation.target;
            if (
              mutation.attributeName === "style" &&
              hasUnprocessedShikiColor(target)
            ) {
              addPendingRoot(target);
            } else if (
              mutation.attributeName === "class" &&
              target.matches("pre.shiki")
            ) {
              addPendingRoot(target);
            } else if (
              (mutation.attributeName === "class" ||
                mutation.attributeName === "data-code" ||
                mutation.attributeName === "aria-label") &&
              target.matches(COPY_BUTTON_SELECTOR) &&
              target.getAttribute("data-freedium-copy-bound") !== "true"
            ) {
              addPendingRoot(target);
            }
            continue;
          }

          for (const node of mutation.addedNodes) {
            if (node.nodeType !== 1) {
              continue;
            }

            // Replacing a source button produces an already-bound clone. It
            // has no new work to do and skipping it avoids observer churn.
            if (
              node.matches(COPY_BUTTON_SELECTOR) &&
              node.getAttribute("data-freedium-copy-bound") === "true"
            ) {
              continue;
            }

            addPendingRoot(node);
          }
        }
        if (pendingRoots.size > 0) {
          schedulePendingRoots();
        }
      }

      const observer = new MutationObserver(onMutations);
      window._freediumCopyObserver = observer;

      observer.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ["class", "style", "data-code", "aria-label"],
      });

      // One initial scan handles markup that was present at injection time.
      // All later hydration is handled from the added subtree, avoiding the
      // repeated whole-document scans previously scheduled at 250/900/1600ms.
      processCodeSubtree(document);

      function cleanup() {
        if (cleanupTimer !== null) {
          clearTimeout(cleanupTimer);
          cleanupTimer = null;
        }
        if (scheduledFrame !== null) {
          if (typeof window.cancelAnimationFrame === "function") {
            window.cancelAnimationFrame(scheduledFrame);
          }
          scheduledFrame = null;
        }
        if (scheduledTimer !== null) {
          clearTimeout(scheduledTimer);
          scheduledTimer = null;
        }
        pendingRoots.clear();
        observer.disconnect();
        if (window._freediumCopyObserver === observer) {
          window._freediumCopyObserver = null;
        }
        if (window._freediumCodeDomCleanup === cleanup) {
          window._freediumCodeDomCleanup = null;
        }
      }

      window._freediumCodeDomCleanup = cleanup;
      cleanupTimer = setTimeout(function () {
        observer.disconnect();
        if (window._freediumCopyObserver === observer) {
          window._freediumCopyObserver = null;
        }
        cleanupTimer = null;
      }, 10000);
    } catch (e) {
      console.warn("Failed to override copy functionality:", e);
    }
  }

  function overrideCopyButton(button) {
    if (button.getAttribute("data-freedium-copy-bound") === "true") {
      return;
    }

    const codeContent = getCopyButtonText(button);
    if (!codeContent) {
      return;
    }

    const newButton = button.cloneNode(true);
    newButton.setAttribute("type", "button");
    newButton.setAttribute("data-freedium-copy-bound", "true");
    newButton.setAttribute("aria-label", "Copy code");
    newButton.contentCopy = codeContent;

    button.parentNode.replaceChild(newButton, button);

    newButton.addEventListener("click", function (event) {
      event.preventDefault();
      event.stopImmediatePropagation();

      copyTextToClipboard(newButton.contentCopy || codeContent)
        .then(function () {
          setCopyButtonSuccess(newButton);
          if (window.Toaster && window.Toaster.postMessage) {
            window.Toaster.postMessage("Text copied to clipboard");
          }
        })
        .catch(function (err) {
          console.error("Failed to copy text:", err);
        });
    });
  }

  function getCopyButtonText(button) {
    const dataCode = button.getAttribute("data-code");
    if (dataCode && dataCode.trim()) {
      return dataCode;
    }

    if (button.contentCopy && String(button.contentCopy).trim()) {
      return String(button.contentCopy);
    }

    const preElement = button.closest("pre");
    if (preElement) {
      const codeElement = preElement.querySelector("code");
      if (codeElement) {
        return codeElement.textContent || codeElement.innerText || "";
      }
    }

    const wrapper = button.closest(".relative");
    if (wrapper) {
      const codeElement =
        wrapper.querySelector("pre:not(.hidden) code") ||
        wrapper.querySelector("pre code");
      if (codeElement) {
        return codeElement.textContent || codeElement.innerText || "";
      }
    }

    return "";
  }

  function copyTextToClipboard(textToCopy) {
    if (!textToCopy) {
      return Promise.reject(new Error("No content to copy"));
    }

    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(textToCopy).catch(function (err) {
        console.warn("Modern clipboard failed, trying fallback:", err);
        return fallbackCopyText(textToCopy);
      });
    }

    return fallbackCopyText(textToCopy);
  }

  function fallbackCopyText(textToCopy) {
    return new Promise(function (resolve, reject) {
      try {
        const textArea = document.createElement("textarea");
        textArea.value = textToCopy;
        textArea.setAttribute("readonly", "");
        textArea.style.position = "fixed";
        textArea.style.left = "-999999px";
        textArea.style.top = "-999999px";
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        const successful = document.execCommand("copy");
        textArea.remove();

        if (successful) {
          resolve();
        } else {
          reject(new Error("execCommand copy failed"));
        }
      } catch (err) {
        reject(err);
      }
    });
  }

  function setCopyButtonSuccess(button) {
    const ready = button.querySelector(".ready");
    const success = button.querySelector(".success");
    if (!ready || !success) {
      return;
    }

    ready.classList.add("hidden");
    ready.classList.remove("block");
    success.classList.remove("hidden");
    success.classList.add("block");

    const toggleMs = Number(button.getAttribute("data-toggle-ms")) || 1200;
    setTimeout(function () {
      ready.classList.remove("hidden");
      ready.classList.add("block");
      success.classList.add("hidden");
      success.classList.remove("block");
    }, toggleMs);
  }

  function notifyThemeApplied() {
    try {
      if (window.themeApplied && window.themeApplied.postMessage) {
        window.themeApplied.postMessage("done");
      }
    } catch (e) {
      console.warn("Failed to call Flutter handler:", e);
    }
  }

  function recolorShikiToken(el) {
    var style = el.getAttribute("style") || "";
    var match = style.match(/(?:^|;)\s*color\s*:\s*(#[0-9a-fA-F]{3,8})/i);
    if (!match) {
      return;
    }
    var replacement = SHIKI_HEX_TO_VAR[match[1].toLowerCase()];
    if (replacement) {
      // Keep the app role as a CSS variable so a theme change updates
      // existing tokens without another document scan.
      el.style.setProperty("color", replacement, "important");
    }
  }

  function hasUnprocessedShikiColor(el) {
    if (!el.matches(SHIKI_TOKEN_SELECTOR)) {
      return false;
    }
    var style = el.getAttribute("style") || "";
    var match = style.match(/(?:^|;)\s*color\s*:\s*(#[0-9a-fA-F]{3,8})/i);
    return !!(match && SHIKI_HEX_TO_VAR[match[1].toLowerCase()]);
  }

  function installReadingProgressTracking() {
    if (
      window._freediumReadingProgressFlush &&
      window.ReadingProgress &&
      window.ReadingProgress.postMessage
    ) {
      window._freediumReadingProgressFlush();
    }
    if (window._freediumReadingProgressHandler) {
      window.removeEventListener(
        "scroll",
        window._freediumReadingProgressHandler
      );
    }
    if (window._freediumReadingProgressVisibilityHandler) {
      document.removeEventListener(
        "visibilitychange",
        window._freediumReadingProgressVisibilityHandler
      );
    }
    if (window._freediumReadingProgressPageHideHandler) {
      window.removeEventListener(
        "pagehide",
        window._freediumReadingProgressPageHideHandler
      );
    }
    clearTimeout(window._freediumReadingProgressTimer);
    window._freediumReadingProgressTimer = null;
    window._freediumReadingProgressFlush = null;

    if (!window.ReadingProgress || !window.ReadingProgress.postMessage) {
      return;
    }

    function reportProgress() {
      const root = document.documentElement;
      const body = document.body;
      const height = Math.max(
        root ? root.scrollHeight : 0,
        body ? body.scrollHeight : 0
      );
      const scrollable = Math.max(1, height - window.innerHeight);
      const progress = Math.min(1, Math.max(0, window.scrollY / scrollable));
      const message = JSON.stringify({
        url: window.location.href,
        pageToken: window._freediumReadingProgressPageToken,
        progress: progress.toFixed(3),
      });
      if (message === window._freediumLastReadingProgressMessage) return;

      window._freediumLastReadingProgressMessage = message;
      window.ReadingProgress.postMessage(message);
    }

    window._freediumReadingProgressFlush = function () {
      clearTimeout(window._freediumReadingProgressTimer);
      window._freediumReadingProgressTimer = null;
      reportProgress();
    };

    window._freediumReadingProgressHandler = function () {
      clearTimeout(window._freediumReadingProgressTimer);
      window._freediumReadingProgressTimer = setTimeout(function () {
        window._freediumReadingProgressTimer = null;
        reportProgress();
      }, 400);
    };

    window._freediumReadingProgressVisibilityHandler = function () {
      if (document.visibilityState === "hidden") {
        window._freediumReadingProgressFlush();
      }
    };

    window._freediumReadingProgressPageHideHandler = function () {
      window._freediumReadingProgressFlush();
    };

    window.addEventListener("scroll", window._freediumReadingProgressHandler, {
      passive: true,
    });
    document.addEventListener(
      "visibilitychange",
      window._freediumReadingProgressVisibilityHandler
    );
    window.addEventListener(
      "pagehide",
      window._freediumReadingProgressPageHideHandler
    );
  }

  function extractArticleMeta() {
    try {
      const articleHeader = document.querySelector("article header");
      const titleEl =
        (articleHeader && articleHeader.querySelector("h1")) ||
        document.querySelector("article h1") ||
        document.querySelector("div.font-sans > h1") ||
        document.querySelector("h1");
      const title = titleEl
        ? titleEl.innerText.trim()
        : document.title
            .replace(/ [|\-–] Freedium$/i, "")
            .replace(/ by .+ - Freedium$/i, "")
            .trim();

      const authorEl =
        (articleHeader &&
          (articleHeader.querySelector("img + div .font-semibold") ||
            articleHeader.querySelector(".font-semibold"))) ||
        document.querySelector("div.flex-grow > a[href*='medium.com']");
      const author = authorEl
        ? authorEl.innerText.trim().replace(/^By\s+/i, "")
        : "";

      let readTime = "";
      const readTimeScope = articleHeader || document;
      const textEls = readTimeScope.querySelectorAll("p, span, div");
      for (let i = 0; i < textEls.length; i++) {
        const txt = (textEls[i].innerText || "").replace(/\s+/g, " ").trim();
        const match = txt.match(/\b\d+\s+min read\b/i);
        if (match) {
          readTime = match[0];
          break;
        }
      }

      let heroImg = "";
      const heroEl =
        document.querySelector("article img[alt='Post cover image']") ||
        document.querySelector("article img[data-zoom-src]") ||
        document.querySelector("img[alt='Preview image']") ||
        document.querySelector("div.font-sans img");
      const heroSrc =
        heroEl &&
        (heroEl.currentSrc ||
          heroEl.src ||
          heroEl.getAttribute("src") ||
          heroEl.getAttribute("data-zoom-src"));
      if (heroSrc && !heroSrc.startsWith("data:")) {
        try {
          heroImg = new URL(
            heroSrc,
            document.baseURI || window.location.href
          ).href;
        } catch (_) {
          heroImg = heroSrc;
        }
      }

      if (window.ArticleMeta && window.ArticleMeta.postMessage) {
        window.ArticleMeta.postMessage(
          JSON.stringify({
            title: title,
            author: author,
            readTime: readTime,
            heroImageUrl: heroImg,
          })
        );
      }
    } catch (e) {
      console.warn("ArticleMeta extraction failed:", e);
    }
  }
})();
