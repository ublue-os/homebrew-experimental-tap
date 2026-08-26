cask "winboat" do
  arch arm: "arm64", intel: "x64"
  os linux: "linux"

  version "0.9.2"
  sha256 "aa5a6ae3e28367dce234d146d4866cea02ae840713b65d8d7456eb277a4e8c98"

  url "https://github.com/TibixDev/winboat/releases/download/v#{version}/winboat-#{version}-x64.tar.gz"
  name "Winboat"
  desc "Run Windows apps on Linux with seamless integration"
  homepage "https://www.winboat.app/"

  livecheck do
    url :url
    strategy :github_latest
  end

  binary "winboat-#{version}-x64/winboat"

  preflight do
    require "open-uri"

    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/512x512/apps"

    # Download icon from GitHub repo
    icon_url = "https://raw.githubusercontent.com/TibixDev/winboat/main/src/renderer/public/img/winboat_logo.png"
    icon_path = "#{Dir.home}/.local/share/icons/hicolor/512x512/apps/winboat.png"

    URI.parse(icon_url).open do |remote_file|
      File.binwrite(icon_path, remote_file.read)
    end

    desktop_file = <<~EOS
      [Desktop Entry]
      Name=Winboat
      Comment=Run Windows apps on Linux with seamless integration
      Exec=#{HOMEBREW_PREFIX}/bin/winboat %U
      Terminal=false
      Type=Application
      Icon=winboat
      Categories=Utility;
    EOS

    File.write("#{Dir.home}/.local/share/applications/winboat.desktop", desktop_file)
  end

  zap trash: [
    "~/.config/winboat",
    "~/.local/share/applications/winboat.desktop",
    "~/.local/share/icons/hicolor/512x512/apps/winboat.png",
    "~/.local/share/winboat",
  ]

  caveats do
    <<~EOS
      Winboat requires the following dependencies to be installed:
        - Docker (for running Windows containers)
        - FreeRDP (for remote desktop protocol support)
      You can install FreeRDP from flatpak:
        flatpak install com.freerdp.FreeRDP
    EOS
  end
end
