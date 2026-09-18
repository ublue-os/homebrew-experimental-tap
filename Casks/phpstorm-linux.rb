cask "phpstorm-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.3,262.10968.76"
  sha256 arm64_linux:  "98378c897dc8be2438c4fccc3a3e6dc3cee4acfd1a54402b5c3a92a856fcfd66",
         x86_64_linux: "d9fad320592fac25e44753ef03a8f68a86f7ef5e0e89ffc86991b0467b1a7b87"

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
  depends_on linux: :any

  binary "phpstorm/bin/phpstorm"
  artifact "jetbrains-phpstorm.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-phpstorm.desktop"
  artifact "phpstorm/bin/phpstorm.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/phpstorm.svg"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    move "PhpStorm-*", "phpstorm", source_glob: true
    touch "phpstorm/bin/phpstorm64.vmoptions"
    inreplace "phpstorm/bin/phpstorm64.vmoptions", /\z/, "-Dide.no.platform.update=true\n"
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-phpstorm.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=PhpStorm
      Comment=A smart IDE for PHP and Web
      Exec={{HOMEBREW_PREFIX}}/bin/phpstorm %u
      Icon=phpstorm
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;php;
      Terminal=false
      StartupWMClass=jetbrains-phpstorm
      StartupNotify=true
    EOS
  end

  postflight_steps do
    mkdir_p "xdg-user-data"
    symlink ".local/share", "xdg-user-data/share", source_base: :home
    run "/usr/bin/xdg-icon-resource", args: ["forceupdate"], must_succeed: false,
                                  env: { "XDG_DATA_HOME" => "{{staged_path}}/xdg-user-data/share" },
                                  writable_paths: [".local/share/icons/hicolor"], writable_base: :home
  end

  zap trash: [
    "#{Dir.home}/.cache/JetBrains/PhpStorm#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/PhpStorm#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/PhpStorm#{version.major_minor}",
  ]
end
