cask "datagrip-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3.1,253.29346.125"
  sha256 x86_64_linux: "37d8587ee1b2f65c598100ddfa753ee3239ecae5ff8914a941e23fdb42bbdd8a",
         arm64_linux:  "166fde53569a12041ccbb05b8edc7e75015019be47401e2937893ea1b008d11e"

  url "https://download.jetbrains.com/datagrip/datagrip-#{version.csv.first}#{arch}.tar.gz"
  name "DataGrip"
  desc "Databases and SQL IDE"
  homepage "https://www.jetbrains.com/datagrip/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=DG&latest=true&type=release"
    strategy :json do |json|
      json["DG"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/datagrip-linux/#{version}/DataGrip-#{version.csv.first}/bin/datagrip"
  artifact "jetbrains-datagrip.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-datagrip.desktop"
  artifact "DataGrip-#{version.csv.first}/bin/datagrip.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/datagrip.svg"

  preflight do
    File.write("#{staged_path}/DataGrip-#{version.csv.first}/bin/datagrip64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-datagrip.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=DataGrip
      Comment=The IDE for databases and SQL
      Exec=#{HOMEBREW_PREFIX}/bin/datagrip %u
      Icon=datagrip
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;database;sql;
      Terminal=false
      StartupWMClass=jetbrains-datagrip
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/DataGrip#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/DataGrip#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/DataGrip#{version.major_minor}",
  ]
end
