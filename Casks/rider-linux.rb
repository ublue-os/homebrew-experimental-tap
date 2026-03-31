cask "rider-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2026.1,261.22158.335"
  sha256 x86_64_linux: "b2b611f3e7cb13dd46ef7158e21aaab13cc6d4b25ba600cda219497d1d4a0e51",
         arm64_linux:  "2125027ff14cea281a0047d955f2f7181a4e6ba7cc7b97189da3be79c26f5310"

  url "https://download.jetbrains.com/rider/JetBrains.Rider-#{version.csv.first}#{arch}.tar.gz"
  name "Rider"
  desc ".NET IDE"
  homepage "https://www.jetbrains.com/rider/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RD&latest=true&type=release"
    strategy :json do |json|
      json["RD"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/rider-linux/#{version}/JetBrains Rider-#{version.csv.first}/bin/rider"
  artifact "jetbrains-rider.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-rider.desktop"
  artifact "JetBrains Rider-#{version.csv.first}/bin/rider.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/rider.svg"

  preflight do
    File.write("#{staged_path}/JetBrains Rider-#{version.csv.first}/bin/rider64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-rider.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=Rider
      Comment=All-in-one IDE for .NET and game development
      Exec=#{HOMEBREW_PREFIX}/bin/rider %u
      Icon=rider
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;c#;f#;dotnet;.net;
      Terminal=false
      StartupWMClass=jetbrains-rider
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/Rider#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/Rider#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/Rider#{version.major_minor}",
  ]
end
