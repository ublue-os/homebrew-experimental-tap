cask "gitkraken-linux" do
  version "12.6.2"
  sha256 "69a4195eb398aa5e159efbd57be6c9cddbb6fa30ff8dafbc7fb3f23729115b11"

  url "https://api.gitkraken.dev/releases/production/linux/x64/#{version}/gitkraken-amd64.tar.gz"
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

  preflight_steps do
    mkdir_p ".local/share/applications", base: :home

    write_file "gitkraken.desktop", <<~EOS
      [Desktop Entry]
      Name=GitKraken
      Comment=Git client focusing on productivity
      Exec={{HOMEBREW_PREFIX}}/bin/gitkraken %U
      Icon={{staged_path}}/gitkraken/gitkraken.png
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
