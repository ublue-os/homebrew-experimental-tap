cask "goland-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.1,262.9437.195"
  sha256 arm64_linux:  "0ff8085bb9c896ac3a478fa0d63b21f991c7f37e900598abaa5a855f8c127712",
         x86_64_linux: "44a2cb6dda302340ade6e52adfff291c9fd62074c53d312b7f4268ddaa0a2159"

  url "https://download.jetbrains.com/go/goland-#{version.csv.first}#{arch}.tar.gz"
  name "GoLand"
  desc "Go (golang) IDE"
  homepage "https://www.jetbrains.com/goland/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=GO&latest=true&type=release"
    strategy :json do |json|
      json["GO"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"
  depends_on linux: :any

  binary "#{HOMEBREW_PREFIX}/Caskroom/goland-linux/#{version}/GoLand-#{version.csv.first}/bin/goland"
  artifact "jetbrains-goland.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-goland.desktop"
  artifact "GoLand-#{version.csv.first}/bin/goland.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/goland.svg"

  preflight do
    File.write("#{staged_path}/GoLand-#{version.csv.first}/bin/goland64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-goland.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=GoLand
      Comment=An IDE for Go and Web
      Exec=#{HOMEBREW_PREFIX}/bin/goland %u
      Icon=goland
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;go;golang;
      Terminal=false
      StartupWMClass=jetbrains-goland
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/GoLand#{version.major_minor}",
  ]
end
