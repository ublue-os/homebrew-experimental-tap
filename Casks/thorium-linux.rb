cask "thorium-linux" do
  version "138.0.7204.303"
  sha256 "b17cd482a67d968a6b04239b1d72d18e45b5e44cc514c05baaaab1b90f992230"

  # Uses the AVX2 build (recommended for modern CPUs manufactured after ~2013)
  url "https://github.com/Alex313031/thorium/releases/download/M#{version}/Thorium_Browser_#{version}_AVX2.AppImage",
      verified: "github.com/Alex313031/thorium/"
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

  preflight do
    appimage_path = "#{staged_path}/Thorium_Browser_#{version}_AVX2.AppImage"
    system "chmod", "+x", appimage_path
    system appimage_path, "--appimage-extract", chdir: staged_path
    FileUtils.rm appimage_path
  end

  binary "squashfs-root/thorium-browser", target: "thorium-browser"

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/256x256/apps"

    icon_source = "#{staged_path}/squashfs-root/product_logo_256.png"
    icon_target = "#{xdg_data}/icons/hicolor/256x256/apps/thorium-browser.png"
    FileUtils.cp(icon_source, icon_target) if File.exist?(icon_source)

    desktop_source = "#{staged_path}/squashfs-root/thorium-browser.desktop"
    if File.exist?(desktop_source)
      desktop_content = File.read(desktop_source)
      desktop_content.gsub!(/^Exec=thorium-browser/, "Exec=#{HOMEBREW_PREFIX}/bin/thorium-browser")
      desktop_content.gsub!(/^Icon=.*/, "Icon=#{icon_target}")
      File.write("#{xdg_data}/applications/thorium-browser.desktop", desktop_content)
    else
      File.write("#{xdg_data}/applications/thorium-browser.desktop", <<~EOS)
        [Desktop Entry]
        Name=Thorium Browser
        Comment=Fast, privacy-hardened Chromium browser
        GenericName=Web Browser
        Exec=#{HOMEBREW_PREFIX}/bin/thorium-browser %U
        Icon=#{icon_target}
        Type=Application
        StartupNotify=true
        StartupWMClass=thorium-browser
        Categories=Network;WebBrowser;
        MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
        Keywords=browser;web;chromium;thorium;
      EOS
    end
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm_f "#{xdg_data}/applications/thorium-browser.desktop"
    FileUtils.rm_f "#{xdg_data}/icons/hicolor/256x256/apps/thorium-browser.png"
  end

  zap trash: [
    "~/.config/thorium",
    "~/.cache/thorium",
  ]
end
