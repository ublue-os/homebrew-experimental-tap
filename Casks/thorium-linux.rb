cask "thorium-linux" do
  version "138.0.7204.303"
  sha256 "b17cd482a67d968a6b04239b1d72d18e45b5e44cc514c05baaaab1b90f992230"

  # Uses the AVX2 build (recommended for modern CPUs manufactured after ~2013)
  url "https://github.com/Alex313031/thorium/releases/download/M#{version}/Thorium_Browser_#{version}_AVX2.AppImage"
  name "Thorium Browser"
  desc "Fast, privacy-hardened Chromium browser with compiler optimizations"
  homepage "https://thorium.rocks/"

  livecheck do
    url "https://api.github.com/repos/Alex313031/thorium/releases"
    strategy :json do |json|
      # Find the latest release that has assets
      releases_with_assets = json.select { |r| r["assets"]&.any? && !r["prerelease"] }
      next if releases_with_assets.empty?

      releases_with_assets.first["tag_name"]&.sub(/^M/, "")
    end
  end

  depends_on formula: "squashfs"

  binary "squashfs-root/thorium-browser", target: "thorium-browser"

  preflight_steps do
    # Normalise the versioned AppImage filename before extraction.
    move "Thorium_Browser_*.AppImage", "thorium-browser.AppImage", source_glob: true
    set_permissions "thorium-browser.AppImage", "+x"
    run "thorium-browser.AppImage", args: ["--appimage-extract"], base: :staged_path,
        chdir: "{{staged_path}}"
    remove "thorium-browser.AppImage"
  end

  postflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/256x256/apps", base: :home

    if_path_exists "squashfs-root/product_logo_256.png" do
      copy "squashfs-root/product_logo_256.png",
           ".local/share/icons/hicolor/256x256/apps/thorium-browser.png", target_base: :home
    end

    if_path_exists "squashfs-root/thorium-browser.desktop" do
      copy "squashfs-root/thorium-browser.desktop", ".local/share/applications/thorium-browser.desktop",
           target_base: :home
      inreplace ".local/share/applications/thorium-browser.desktop", /^Exec=thorium-browser/,
                "Exec={{HOMEBREW_PREFIX}}/bin/thorium-browser", base: :home, audit_result: false
      inreplace ".local/share/applications/thorium-browser.desktop", /^Icon=.*/,
                "Icon=thorium-browser", base: :home, audit_result: false
    end
    unless_path_exists "squashfs-root/thorium-browser.desktop" do
      write_file ".local/share/applications/thorium-browser.desktop", <<~EOS, base: :home
        [Desktop Entry]
        Name=Thorium Browser
        Comment=Fast, privacy-hardened Chromium browser
        GenericName=Web Browser
        Exec={{HOMEBREW_PREFIX}}/bin/thorium-browser %U
        Icon=thorium-browser
        Type=Application
        StartupNotify=true
        StartupWMClass=thorium-browser
        Categories=Network;WebBrowser;
        MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
        Keywords=browser;web;chromium;thorium;
      EOS
    end
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/thorium-browser.desktop", base: :home
    remove ".local/share/icons/hicolor/256x256/apps/thorium-browser.png", base: :home
  end

  zap trash: [
    "~/.cache/thorium",
    "~/.config/thorium",
  ]
end
