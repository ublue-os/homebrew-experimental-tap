cask "zed-linux@preview" do
  version "0.233.1"
  sha256 "7693529112bb477c9aa3f9e09bd20a9d0ce20c2f606d3aef555f4636a564c2c0"

  url "https://zed.dev/api/releases/preview/#{version}/zed-linux-x86_64.tar.gz"
  name "Zed Preview"
  desc "High-performance, multiplayer code editor (preview build)"
  homepage "https://zed.dev/"

  livecheck do
    url "https://zed.dev/api/releases/latest?asset=zed-linux-x86_64.tar.gz&preview=1&os=linux&arch=x86_64"
    strategy :json do |json|
      json["version"]
    end
  end

  binary "zed-preview.app/bin/zed", target: "zed-preview"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons"
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    desktop_content = File.read("#{staged_path}/zed-preview.app/share/applications/dev.zed.Zed-Preview.desktop")
    desktop_content.gsub!(/^TryExec=.*/, "TryExec=#{HOMEBREW_PREFIX}/bin/zed-preview")
    desktop_content.gsub!(/^Exec=zed/, "Exec=#{HOMEBREW_PREFIX}/bin/zed-preview")
    desktop_content.gsub!(/^Icon=.*/, "Icon=zed-preview")
    File.write("#{xdg_data}/applications/dev.zed.Zed-Preview.desktop", desktop_content)
    FileUtils.cp("#{staged_path}/zed-preview.app/share/icons/hicolor/512x512/apps/zed.png",
                 "#{xdg_data}/icons/zed-preview.png")
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm("#{xdg_data}/applications/dev.zed.Zed-Preview.desktop")
    FileUtils.rm("#{xdg_data}/icons/zed-preview.png")
  end

  zap trash: [
    "#{ENV.fetch("XDG_CACHE_HOME", "#{Dir.home}/.cache")}/zed",
    "#{ENV.fetch("XDG_CONFIG_HOME", "#{Dir.home}/.config")}/zed",
    "#{ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")}/zed",
  ]
end
