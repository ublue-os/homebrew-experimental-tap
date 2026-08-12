cask "gitkraken-linux" do
  version "12.3.1"
  sha256 "377f3b94ff1df9225906bc8134d505b14c1e6be82dea07463e14a62439b3319d"

  url "https://api.gitkraken.dev/releases/production/linux/x64/#{version}/gitkraken-amd64.tar.gz",
      verified: "api.gitkraken.dev/releases/production/"
  name "GitKraken"
  desc "Git client focusing on productivity"
  homepage "https://www.gitkraken.com/"

  livecheck do
    url "https://release.gitkraken.com/linux/RELEASES?v=0.0.0&linux=999"
    strategy :json do |json|
      json["name"]
    end
  end

  auto_updates true

  binary "gitkraken/gitkraken"
  artifact "gitkraken.desktop",
           target: "#{Dir.home}/.local/share/applications/gitkraken.desktop"

  preflight do
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"

    File.write "#{staged_path}/gitkraken.desktop", <<~EOS
      [Desktop Entry]
      Name=GitKraken
      Comment=Git client focusing on productivity
      Exec=#{HOMEBREW_PREFIX}/bin/gitkraken %U
      Icon=#{staged_path}/gitkraken/gitkraken.png
      Terminal=false
      Type=Application
      Categories=Development;RevisionControl;
      StartupWMClass=GitKraken
    EOS
  end

  zap trash: [
    "~/.cache/GitKraken",
    "~/.config/GitKraken",
    "~/.gitkraken",
    "~/.local/share/applications/gitkraken.desktop",
  ]
end
