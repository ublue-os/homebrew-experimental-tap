cask "goland-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.3,262.10968.67"
  sha256 arm64_linux:  "6d4ad1342ce1c2a738fd93f6a19f2a71245c04fd295a162a486305fc3f13e2a5",
         x86_64_linux: "0af3e82e63f906824c49c41fdbf6c6e679a02ab94ab11fc04f27050a6970d76f"

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

  binary "goland/bin/goland"
  artifact "jetbrains-goland.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-goland.desktop"
  artifact "goland/bin/goland.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/goland.svg"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    remove "goland", recursive: true
    move "GoLand-*", "goland", source_glob: true
    touch "goland/bin/goland64.vmoptions"
    inreplace "goland/bin/goland64.vmoptions", /\z/, "-Dide.no.platform.update=true\n"
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-goland.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=GoLand
      Comment=An IDE for Go and Web
      Exec={{HOMEBREW_PREFIX}}/bin/goland %u
      Icon=goland
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;go;golang;
      Terminal=false
      StartupWMClass=jetbrains-goland
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
    "#{Dir.home}/.cache/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/GoLand#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/GoLand#{version.major_minor}",
  ]
end
