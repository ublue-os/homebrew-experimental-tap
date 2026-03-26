cask "rustrover-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3.5,253.31033.204"
  sha256 x86_64_linux: "db21193965280fa10bb34592bdd312652540980fcbb282b27c9891db423ce9a4",
         arm64_linux:  "b65f25c4c1fa5c7fb6546aafeafc461238c02debda125ed5033b3d2c08f0b4f4"

  url "https://download.jetbrains.com/rustrover/RustRover-#{version.csv.first}#{arch}.tar.gz"
  name "RustRover"
  desc "Rust IDE"
  homepage "https://www.jetbrains.com/rustrover/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RR&latest=true&type=release"
    strategy :json do |json|
      json["RR"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/rustrover-linux/#{version}/RustRover-#{version.csv.first}/bin/rustrover"
  artifact "jetbrains-rustrover.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-rustrover.desktop"
  artifact "RustRover-#{version.csv.first}/bin/rustrover.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/rustrover.svg"

  preflight do
    File.write("#{staged_path}/RustRover-#{version.csv.first}/bin/rustrover64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-rustrover.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=RustRover
      Comment=A powerful IDE for Rust
      Exec=#{HOMEBREW_PREFIX}/bin/rustrover %u
      Icon=rustrover
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;rust;
      Terminal=false
      StartupWMClass=jetbrains-rustrover
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/RustRover#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/RustRover#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/RustRover#{version.major_minor}",
  ]
end
