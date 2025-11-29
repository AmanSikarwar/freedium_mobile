(function () {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", applyTheme);
  } else {
    applyTheme();
  }

  function applyTheme() {
    try {
      const isDarkMode = "%IS_DARK_MODE%";

      const styleSheet = document.createElement("style");
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
      customCSS.textContent = `%CUSTOM_CSS_CONTENT%`;
      document.head.appendChild(customCSS);

      const desiredHljsTheme = isDarkMode === "true" ? "github-dark" : "github";
      try {
        const existingLink = document.querySelector(
          'link[href*="highlight.js/styles"]'
        );
        if (existingLink && !existingLink.href.includes(desiredHljsTheme)) {
          existingLink.href = `https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/${desiredHljsTheme}.min.css`;
        } else if (!existingLink) {
          const link = document.createElement("link");
          link.rel = "stylesheet";
          link.href = `https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/${desiredHljsTheme}.min.css`;
          document.head.appendChild(link);
        }
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

        const observer = new MutationObserver(function (mutations) {
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

        observer.observe(document.body, {
          childList: true,
          subtree: true,
        });

        setTimeout(() => {
          observer.disconnect();
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
