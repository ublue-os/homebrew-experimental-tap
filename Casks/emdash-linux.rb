cask "emdash-linux" do
  version "1.1.22"
  sha256 "682cf2a715d41fb7bd7a41d63ae70c80d5e143d27ecd47f00a747c3a4054f84d"

  url "https://github.com/generalaction/emdash/releases/download/v#{version}/emdash-x86_64.AppImage"
  name "Emdash"
  desc "Agentic development environment for running multiple coding agents in parallel"
  homepage "https://emdash.sh/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "squashfs"

  binary "squashfs-root/emdash", target: "emdash"
  artifact "squashfs-root/usr/share/icons/hicolor/512x512/apps/emdash.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/512x512/apps/emdash.png"
  artifact "squashfs-root/emdash.desktop",
           target: "#{Dir.home}/.local/share/applications/emdash.desktop"

  preflight do
    appimage_path = "#{staged_path}/emdash-x86_64.AppImage"
    system "chmod", "+x", appimage_path
    system appimage_path, "--appimage-extract", chdir: staged_path
    FileUtils.rm(appimage_path)
  end

  postflight do
    desktop_target = "#{Dir.home}/.local/share/applications/emdash.desktop"
    if File.exist?(desktop_target)
      desktop_content = File.read(desktop_target)
      desktop_content.gsub!(/^Exec=AppRun/, "Exec=#{HOMEBREW_PREFIX}/bin/emdash")
      desktop_content.gsub!(/^Icon=.*/,
                            "Icon=#{Dir.home}/.local/share/icons/hicolor/512x512/apps/emdash.png")
      File.write(desktop_target, desktop_content)
    end
  end

  uninstall_postflight do
    FileUtils.rm("#{Dir.home}/.local/share/icons/hicolor/512x512/apps/emdash.png")
    FileUtils.rm("#{Dir.home}/.local/share/applications/emdash.desktop")
  end

  zap trash: "~/.config/emdash"
end
