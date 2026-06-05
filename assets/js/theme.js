(function () {
  const THEME_MARKER = "data-freedium-theme-applied";
  const COPY_BUTTON_SELECTOR =
    ".hljs-copy, button.code-copy-btn[data-code], button[aria-label='Copy code'][data-code]";

  if (document.documentElement.hasAttribute(THEME_MARKER)) {
    console.log("Freedium theme already applied, reapplying");
  }
  document.documentElement.setAttribute(THEME_MARKER, Date.now().toString());

  document
    .querySelectorAll("style[data-freedium-injected]")
    .forEach(function (el) {
      el.remove();
    });

  if (window._freediumCopyObserver) {
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

      const styleSheet = document.createElement("style");
      styleSheet.setAttribute("data-freedium-injected", "vars");
      styleSheet.textContent = `%CSS_VARS%`;
      document.head.appendChild(styleSheet);

      setFreediumTheme(isDark);

      const customCSS = document.createElement("style");
      customCSS.setAttribute("data-freedium-injected", "custom");
      customCSS.textContent = `%CUSTOM_CSS_CONTENT%`;
      document.head.appendChild(customCSS);

      syncLegacyHighlightTheme(isDark);
      lockNativeThemeControls(isDark);
      installCopyButtonOverrides();
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
    };

    Object.keys(freediumTokens).forEach(function (key) {
      root.style.setProperty(key, freediumTokens[key], "important");
    });

    try {
      localStorage.setItem("theme", themeName);
      localStorage.setItem("mode-watcher-mode", themeName);
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
      function overrideCopyButtons() {
        document.querySelectorAll(COPY_BUTTON_SELECTOR).forEach(function (
          button
        ) {
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
        });
      }

      setTimeout(overrideCopyButtons, 250);
      setTimeout(overrideCopyButtons, 900);
      setTimeout(overrideCopyButtons, 1600);

      window._freediumCopyObserver = new MutationObserver(function (
        mutations
      ) {
        for (const mutation of mutations) {
          for (const node of mutation.addedNodes) {
            if (node.nodeType !== 1) {
              continue;
            }

            if (
              (node.matches && node.matches(COPY_BUTTON_SELECTOR)) ||
              (node.querySelector && node.querySelector(COPY_BUTTON_SELECTOR))
            ) {
              setTimeout(overrideCopyButtons, 100);
              return;
            }
          }
        }
      });

      window._freediumCopyObserver.observe(document.body, {
        childList: true,
        subtree: true,
      });

      setTimeout(function () {
        if (window._freediumCopyObserver) {
          window._freediumCopyObserver.disconnect();
          window._freediumCopyObserver = null;
        }
      }, 10000);
    } catch (e) {
      console.warn("Failed to override copy functionality:", e);
    }
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
      const author = authorEl ? authorEl.innerText.trim() : "";

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
          heroImg = new URL(heroSrc, window.location.origin).href;
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
