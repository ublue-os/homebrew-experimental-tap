cask "clion-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.2,262.10315.131"
  sha256 arm64_linux:  "2fe65958061fcb3f99a411ce941547af513b9a573c780863cfacae32202713a0",
         x86_64_linux: "4e0ab3b0710a23c8b6cba8c72301a52282365edd7506db61b4586abc21ea6dfe"

  url "https://download.jetbrains.com/cpp/CLion-#{version.csv.first}#{arch}.tar.gz"
  name "CLion"
  desc "C and C++ IDE"
  homepage "https://www.jetbrains.com/clion/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=CL&latest=true&type=release"
    strategy :json do |json|
      json["CL"]&.map do |release|
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

  binary "#{HOMEBREW_PREFIX}/Caskroom/clion-linux/#{version}/clion-#{version.csv.first}/bin/clion"
  artifact "jetbrains-clion.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-clion.desktop"
  artifact "clion-#{version.csv.first}/bin/clion.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/clion.svg"

  preflight do
    File.write("#{staged_path}/clion-#{version.csv.first}/bin/clion64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-clion.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=CLion
      Comment=A cross-platform C and C++ IDE
      Exec=#{HOMEBREW_PREFIX}/bin/clion %u
      Icon=clion
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;c;c++;
      Terminal=false
      StartupWMClass=jetbrains-clion
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/CLion#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/CLion#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/CLion#{version.major_minor}",
  ]
end
