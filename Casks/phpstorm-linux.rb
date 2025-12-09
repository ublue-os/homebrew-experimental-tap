cask "phpstorm-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3,253.28294.345"
  sha256 x86_64_linux: "eba685d65ac062f157288c7c70839647c482163df90e85930f217a0836927dd2",
         arm64_linux:  "703707490cdc0a547a4045bb2077ff372ce4d3a8928a90918d4bfc8e40d9eb4d"

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
