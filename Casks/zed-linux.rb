cask "zed-linux" do
  version "1.5.3"
  sha256 "fd3ec36b4483a36e1c5fd81a04354f77cebc2c8e7a0ca41708a20f95798da594"

  url "https://github.com/zed-industries/zed/releases/download/v#{version}/zed-linux-x86_64.tar.gz"
  name "Zed"
  desc "High-performance, multiplayer code editor"
  homepage "https://zed.dev/"

  livecheck do
    url :url
    strategy :github_latest
  end

  binary "zed.app/bin/zed"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons"
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    desktop_content = File.read("#{staged_path}/zed.app/share/applications/dev.zed.Zed.desktop")
    desktop_content.gsub!(/^TryExec=.*/, "TryExec=#{HOMEBREW_PREFIX}/bin/zed")
    desktop_content.gsub!(/^Exec=zed/, "Exec=#{HOMEBREW_PREFIX}/bin/zed")
    desktop_content.gsub!(/^Icon=.*/, "Icon=zed")
    File.write("#{xdg_data}/applications/dev.zed.Zed.desktop", desktop_content)
    FileUtils.cp("#{staged_path}/zed.app/share/icons/hicolor/512x512/apps/zed.png",
                 "#{xdg_data}/icons/zed.png")
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm("#{xdg_data}/applications/dev.zed.Zed.desktop")
    FileUtils.rm("#{xdg_data}/icons/zed.png")
  end

  zap trash: [
    "#{ENV.fetch("XDG_CACHE_HOME", "#{Dir.home}/.cache")}/zed",
    "#{ENV.fetch("XDG_CONFIG_HOME", "#{Dir.home}/.config")}/zed",
    "#{ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")}/zed",
  ]
end
