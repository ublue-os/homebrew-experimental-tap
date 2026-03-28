cask "phpstorm-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2026.1,261.22158.283"
  sha256 x86_64_linux: "3a949cfd78389d687d5d1a5537c14b695d46c33f246ccf92f56564dbb8c9ee06",
         arm64_linux:  "4ada12cd2c787f179e07e3e7641e4f084ccf26e5826be1de63dbba8461a55078"

  url "https://download.jetbrains.com/webide/PhpStorm-#{version.csv.first}#{arch}.tar.gz"
  name "PhpStorm"
  desc "PHP IDE by JetBrains"
  homepage "https://www.jetbrains.com/phpstorm/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=PS&latest=true&type=release"
    strategy :json do |json|
      json["PS"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/phpstorm-linux/#{version}/PhpStorm-#{version.csv.second}/bin/phpstorm"
  artifact "jetbrains-phpstorm.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-phpstorm.desktop"
  artifact "PhpStorm-#{version.csv.second}/bin/phpstorm.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/phpstorm.svg"

  preflight do
    File.write("#{staged_path}/PhpStorm-#{version.csv.second}/bin/phpstorm64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-phpstorm.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=PhpStorm
      Comment=A smart IDE for PHP and Web
      Exec=#{HOMEBREW_PREFIX}/bin/phpstorm %u
      Icon=phpstorm
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;php;
      Terminal=false
      StartupWMClass=jetbrains-phpstorm
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/PhpStorm#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/PhpStorm#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/PhpStorm#{version.major_minor}",
  ]
end
