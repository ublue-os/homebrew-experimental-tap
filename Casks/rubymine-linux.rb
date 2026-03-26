cask "rubymine-linux" do
  arch intel: "",
       arm:   "-aarch64"
  os linux: "linux"

  version "2025.3.4,253.32098.44"
  sha256 x86_64_linux: "8bdeb132d0b5d1fd55e795af1798a8be4d09b62c482dee6bdac9d7d220961fc0",
         arm64_linux:  "940a54d00d5a16a014efe993d5eb64ecffb622c48e061ac9818531f52604a66b"

  url "https://download.jetbrains.com/ruby/RubyMine-#{version.csv.first}#{arch}.tar.gz"
  name "RubyMine"
  desc "Ruby on Rails IDE"
  homepage "https://www.jetbrains.com/rubymine/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RM&latest=true&type=release"
    strategy :json do |json|
      json["RM"]&.map do |release|
        version = release["version"]
        build = release["build"]
        next if version.blank? || build.blank?

        "#{version},#{build}"
      end
    end
  end

  auto_updates false
  conflicts_with cask: "jetbrains-toolbox-linux"

  binary "#{HOMEBREW_PREFIX}/Caskroom/rubymine-linux/#{version}/RubyMine-#{version.csv.first}/bin/rubymine"
  artifact "jetbrains-rubymine.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-rubymine.desktop"
  artifact "RubyMine-#{version.csv.first}/bin/rubymine.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/rubymine.svg"

  preflight do
    File.write("#{staged_path}/RubyMine-#{version.csv.first}/bin/rubymine64.vmoptions", "-Dide.no.platform.update=true\n", mode: "a+")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/applications")
    FileUtils.mkdir_p("#{Dir.home}/.local/share/icons/hicolor/scalable/apps")
    File.write("#{staged_path}/jetbrains-rubymine.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Name=RubyMine
      Comment=A Ruby and Rails IDE
      Exec=#{HOMEBREW_PREFIX}/bin/rubymine %u
      Icon=rubymine
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;ruby;rails;
      Terminal=false
      StartupWMClass=jetbrains-rubymine
      StartupNotify=true
    EOS
  end

  postflight do
    system "/usr/bin/xdg-icon-resource", "forceupdate"
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/RubyMine#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/RubyMine#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/RubyMine#{version.major_minor}",
  ]
end
