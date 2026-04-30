cask "dataspell-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2026.1.1,261.23567.176"
  sha256 x86_64_linux: "d73edf6923b65206ff70dfc8854bce693f671728e2d8bef7dd8eaf2a9c1198e8",
         arm64_linux:  "4fb227585e8ad7fdbe18bd74cfaab1c7e8e7f8dfe29c39c275cc8d76b3aed3db"

  url "https://download.jetbrains.com/python/dataspell-#{version.csv.first}#{arch}.tar.gz"
  name "DataSpell"
  desc "IDE for Professional Data Scientists"
  homepage "https://www.jetbrains.com/dataspell/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=DS&latest=true&type=release"
    strategy :json do |json|
      json["DS"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/dataspell-linux/#{version}/dataspell-#{version.csv.first}/bin/dataspell"
  artifact "jetbrains-dataspell.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-dataspell.desktop"
  artifact "dataspell-#{version.csv.first}/bin/dataspell.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/dataspell.svg"

  preflight do
    File.write("#{staged_path}/dataspell-#{version.csv.first}/bin/dataspell64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-dataspell.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=DataSpell
      Comment=The IDE for data analysis
      Exec=#{HOMEBREW_PREFIX}/bin/dataspell %u
      Icon=dataspell
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;python;r;
      Terminal=false
      StartupWMClass=jetbrains-dataspell
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/DataSpell#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/DataSpell#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/DataSpell#{version.major_minor}",
  ]
end
