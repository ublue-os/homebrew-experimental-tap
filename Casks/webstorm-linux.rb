cask "webstorm-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.3,262.10968.77"
  sha256 arm64_linux:  "b21c85335e4e8404a8279750e69ff8bf571d00f12ebbf934b6b239f5bcc6d664",
         x86_64_linux: "3e29741c06799d6609c6d1ff7df720cad73cdb47825879091a577ed496cd00b0"

  url "https://download.jetbrains.com/webstorm/WebStorm-#{version.csv.first}#{arch}.tar.gz"
  name "WebStorm"
  desc "JavaScript IDE"
  homepage "https://www.jetbrains.com/webstorm/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=WS&latest=true&type=release"
    strategy :json do |json|
      json["WS"]&.map do |release|
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

  binary "webstorm/bin/webstorm"
  artifact "jetbrains-webstorm.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-webstorm.desktop"
  artifact "webstorm/bin/webstorm.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/webstorm.svg"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    remove "webstorm", recursive: true
    move "WebStorm-*", "webstorm", source_glob: true
    touch "webstorm/bin/webstorm64.vmoptions"
    inreplace "webstorm/bin/webstorm64.vmoptions", /\z/, "-Dide.no.platform.update=true\n"
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-webstorm.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=WebStorm
      Comment=A JavaScript and TypeScript IDE
      Exec={{HOMEBREW_PREFIX}}/bin/webstorm %u
      Icon=webstorm
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;javascript;typescript;
      Terminal=false
      StartupWMClass=jetbrains-webstorm
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
    "#{Dir.home}/.cache/JetBrains/WebStorm#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/WebStorm#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/WebStorm#{version.major_minor}",
  ]
end
