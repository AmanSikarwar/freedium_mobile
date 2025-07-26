(function () {
  // Defensive programming: wait for DOM to be ready
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

      // Attempt to override highlight.js theme based on dark mode
      const desiredHljsTheme = isDarkMode ? "github-dark" : "github";
      try {
        const existingLink = document.querySelector(
          'link[href*="highlight.js/styles"]'
        );
        if (existingLink && !existingLink.href.includes(desiredHljsTheme)) {
          existingLink.href = `https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/${desiredHljsTheme}.min.css`;
        } else if (!existingLink) {
          const link = document.createElement("link");
          link.rel = "stylesheet";
          link.href = `https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/${desiredHljsTheme}.min.css`;
          document.head.appendChild(link);
        }
      } catch (e) {
        console.warn("Failed to set HLJS theme:", e);
      }

      // Override theme change function with error handling
      try {
        if (window.changeTheme) {
          window.changeTheme = function (themeName) {
            console.log(
              "Freedium App: Preventing web page theme change:",
              themeName
            );
            return false; // Prevent original function execution
          };
        }
      } catch (e) {
        console.warn("Failed to override changeTheme function:", e);
      }

      // Safely call Flutter handler
      try {
        if (
          window.flutter_inappwebview &&
          window.flutter_inappwebview.callHandler
        ) {
          window.flutter_inappwebview.callHandler("themeApplied");
        }
      } catch (e) {
        console.warn("Failed to call Flutter handler:", e);
      }
    } catch (e) {
      console.error("Theme application failed:", e);
      // Still try to signal completion even if theme failed
      try {
        if (
          window.flutter_inappwebview &&
          window.flutter_inappwebview.callHandler
        ) {
          window.flutter_inappwebview.callHandler("themeApplied");
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
