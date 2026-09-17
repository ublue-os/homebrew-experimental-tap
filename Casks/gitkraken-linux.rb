cask "gitkraken-linux" do
  version "12.5.0"
  sha256 "f851909e06751e66072c1b5bdd6ade902f3f37d1dcb7e12522dbbccbf43eaabe"

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
