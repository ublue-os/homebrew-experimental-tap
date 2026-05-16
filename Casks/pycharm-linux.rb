cask "pycharm-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2026.1.2,261.24374.152"
  sha256 on_arch_conditional intel: "91c775be16fb0859f9b18ebd456d88e131cadf337b0ce9f9d8ed187886561966",
                             arm:   "e6b4f25267afade04be6764f6bb16ea1d16159cae3490fbb4f58cc168ecffee3"

  url "https://download.jetbrains.com/python/pycharm-#{version.csv.first}#{arch}.tar.gz"
  name "PyCharm"
  desc "IDE for professional Python development"
  homepage "https://www.jetbrains.com/pycharm/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=PCP&latest=true&type=release"
    strategy :json do |json|
      json["PCP"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/pycharm-linux/#{version}/pycharm-#{version.csv.first}/bin/pycharm"
  artifact "jetbrains-pycharm.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-pycharm.desktop"
  artifact "pycharm-#{version.csv.first}/bin/pycharm.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/pycharm.svg"

  preflight do
    File.write("#{staged_path}/pycharm-#{version.csv.first}/bin/pycharm64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-pycharm.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=PyCharm
      Comment=The Only Python IDE you need
      Exec=#{HOMEBREW_PREFIX}/bin/pycharm %u
      Icon=pycharm
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;python;
      Terminal=false
      StartupWMClass=jetbrains-pycharm
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/PyCharm#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/PyCharm#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/PyCharm#{version.major_minor}",
  ]
end
