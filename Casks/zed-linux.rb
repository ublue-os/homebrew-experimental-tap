cask "zed-linux" do
  version "1.13.1"
  sha256 "9f5638bdf28dd15dd8d82d092577e82de6cd3d0e0c96d2658e24a63df025b9f5"

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
