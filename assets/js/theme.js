(function () {
  const THEME_MARKER = "data-freedium-theme-applied";
  if (document.documentElement.hasAttribute(THEME_MARKER)) {
    console.log("Freedium theme already applied, skipping duplicate injection");
    try {
      if (window.themeApplied && window.themeApplied.postMessage) {
        window.themeApplied.postMessage("done");
      }
    } catch (e) {
      console.warn("Failed to call Flutter handler on skip:", e);
    }
    return;
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
    document.addEventListener("DOMContentLoaded", applyTheme);
  } else {
    applyTheme();
  }

  function applyTheme() {
    try {
      const isDarkMode = "%IS_DARK_MODE%";

      const styleSheet = document.createElement("style");
      styleSheet.setAttribute("data-freedium-injected", "vars");
      styleSheet.textContent = `%CSS_VARS%`;
      document.head.appendChild(styleSheet);

      if (isDarkMode === "true") {
        document.documentElement.classList.add("dark");
        document.documentElement.style.setProperty(
          "--lightense-backdrop",
          "black",
          "important"
        );
        try {
          localStorage.setItem("theme", "dark");
        } catch (e) {
          console.warn("Failed to set localStorage theme:", e);
        }
      } else {
        document.documentElement.classList.remove("dark");
        document.documentElement.style.setProperty(
          "--lightense-backdrop",
          "white",
          "important"
        );
        try {
          localStorage.setItem("theme", "light");
        } catch (e) {
          console.warn("Failed to set localStorage theme:", e);
        }
      }

      const customCSS = document.createElement("style");
      customCSS.setAttribute("data-freedium-injected", "custom");
      customCSS.textContent = `%CUSTOM_CSS_CONTENT%`;
      document.head.appendChild(customCSS);

      // Use the same HLJS version (11.9.0) that Freedium loads in its <head>.
      // Pointing to a different version would load a second HLJS script and
      // cause the stylesheet URL to be replaced with an unmatched version.
      const desiredHljsTheme = isDarkMode === "true" ? "github-dark" : "github";
      const hljsThemeUrl = `https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/${desiredHljsTheme}.min.css`;
      try {
        // Freedium's page script already loaded a highlight.js stylesheet.
        // We swap its href so the correct light/dark theme is applied.
        // Remove ALL existing HLJS style links first to avoid duplicates.
        document
          .querySelectorAll('link[href*="highlight.js"][href*="styles"]')
          .forEach(function (el) {
            el.remove();
          });
        const link = document.createElement("link");
        link.rel = "stylesheet";
        link.href = hljsThemeUrl;
        document.head.appendChild(link);
      } catch (e) {
        console.warn("Failed to set HLJS theme:", e);
      }

      try {
        if (window.changeTheme) {
          window.changeTheme = function (themeName) {
            console.log(
              "Freedium App: Preventing web page theme change:",
              themeName
            );
            return false;
          };
        }
      } catch (e) {
        console.warn("Failed to override changeTheme function:", e);
      }

      try {
        function overrideCopyButtons() {
          const copyButtons = document.querySelectorAll(".hljs-copy");
          copyButtons.forEach((button) => {
            const preElement = button.closest("pre");
            let codeContent = "";

            if (preElement) {
              const codeElement = preElement.querySelector("code");
              if (codeElement) {
                codeContent = codeElement.textContent || codeElement.innerText;
              }
            }

            if (!codeContent && button.contentCopy) {
              codeContent = button.contentCopy;
            }

            const newButton = button.cloneNode(true);
            button.parentNode.replaceChild(newButton, button);

            newButton.contentCopy = codeContent;

            newButton.addEventListener("click", function () {
              const button = this;
              const textToCopy = button.contentCopy || codeContent;

              if (!textToCopy) {
                console.error("No content to copy");
                return;
              }

              function onCopySuccess() {
                if (window.Toaster && window.Toaster.postMessage) {
                  window.Toaster.postMessage("Text copied to clipboard");
                }
              }

              function onCopyError(err) {
                console.error("Failed to copy text: ", err);
              }

              if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard
                  .writeText(textToCopy)
                  .then(onCopySuccess)
                  .catch(function (err) {
                    console.warn(
                      "Modern clipboard failed, trying fallback:",
                      err
                    );
                    try {
                      const textArea = document.createElement("textarea");
                      textArea.value = textToCopy;
                      textArea.style.position = "fixed";
                      textArea.style.left = "-999999px";
                      textArea.style.top = "-999999px";
                      document.body.appendChild(textArea);
                      textArea.focus();
                      textArea.select();
                      const successful = document.execCommand("copy");
                      textArea.remove();

                      if (successful) {
                        onCopySuccess();
                      } else {
                        onCopyError(new Error("execCommand copy failed"));
                      }
                    } catch (fallbackErr) {
                      onCopyError(fallbackErr);
                    }
                  });
              } else {
                try {
                  const textArea = document.createElement("textarea");
                  textArea.value = textToCopy;
                  textArea.style.position = "fixed";
                  textArea.style.left = "-999999px";
                  textArea.style.top = "-999999px";
                  document.body.appendChild(textArea);
                  textArea.focus();
                  textArea.select();
                  const successful = document.execCommand("copy");
                  textArea.remove();

                  if (successful) {
                    onCopySuccess();
                  } else {
                    onCopyError(new Error("execCommand copy failed"));
                  }
                } catch (err) {
                  onCopyError(err);
                }
              }
            });
          });
        }

        // Initial call with delay to ensure DOM is ready
        setTimeout(overrideCopyButtons, 500);
        // Secondary call to catch any late-loaded elements
        setTimeout(overrideCopyButtons, 1500);

        // Store observer reference globally to allow cleanup on re-injection
        window._freediumCopyObserver = new MutationObserver(function (
          mutations
        ) {
          mutations.forEach(function (mutation) {
            if (mutation.addedNodes.length > 0) {
              mutation.addedNodes.forEach(function (node) {
                if (node.nodeType === 1) {
                  if (node.classList && node.classList.contains("hljs-copy")) {
                    setTimeout(overrideCopyButtons, 200);
                  } else if (node.querySelectorAll) {
                    const copyButtons = node.querySelectorAll(".hljs-copy");
                    if (copyButtons.length > 0) {
                      setTimeout(overrideCopyButtons, 200);
                    }
                  }
                }
              });
            }
          });
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

      try {
        if (window.themeApplied && window.themeApplied.postMessage) {
          window.themeApplied.postMessage("done");
        }
      } catch (e) {
        console.warn("Failed to call Flutter handler:", e);
      }

      // Article metadata extraction — best-effort, does not affect reading experience.
      // Selectors verified against the actual Freedium HTML structure.
      setTimeout(function () {
        try {
          // ── Title ──────────────────────────────────────────────────────────
          // Prefer the <h1> inside the .font-sans wrapper (the article header).
          // Fall back to <title>, stripping Freedium's suffix.
          var titleEl = document.querySelector("div.font-sans > h1") ||
                        document.querySelector("h1");
          var title = titleEl
            ? titleEl.innerText.trim()
            : document.title
                .replace(/ [|\-–] Freedium$/i, "")
                .replace(/ by .+ - Freedium$/i, "")
                .trim();

          // ── Author ─────────────────────────────────────────────────────────
          // The author card: div.bg-gray-100 > div.flex > div.flex-grow > a
          // Specifically the first <a> linking to medium.com inside .flex-grow.
          var authorEl =
            document.querySelector("div.flex-grow > a[href*='medium.com']");
          var author = authorEl ? authorEl.innerText.trim() : "";

          // ── Read time ──────────────────────────────────────────────────────
          // Freedium renders read time as a plain <span> containing "min read".
          // There is no data-testid or class that uniquely identifies it.
          var readTime = "";
          var spans = document.querySelectorAll(
            "div.flex.flex-wrap.items-center span"
          );
          for (var i = 0; i < spans.length; i++) {
            var txt = spans[i].innerText || "";
            if (txt.includes("min read")) {
              readTime = txt.trim();
              break;
            }
          }

          // ── Hero image ─────────────────────────────────────────────────────
          // Freedium places a preview image with alt="Preview image" near the top.
          // Fall back to the first non-data image inside the .font-sans wrapper.
          var heroImg = "";
          var heroEl =
            document.querySelector("img[alt='Preview image']") ||
            document.querySelector("div.font-sans img");
          if (heroEl && heroEl.src && !heroEl.src.startsWith("data:")) {
            heroImg = heroEl.src;
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
      }, 800);
    } catch (e) {
      console.error("Theme application failed:", e);
      try {
        if (window.themeApplied && window.themeApplied.postMessage) {
          window.themeApplied.postMessage("done");
        }
      } catch (handlerError) {
        console.error(
          "Failed to call Flutter handler after theme error:",
          handlerError
        );
      }
    }
  }
})();
