cask "rustrover-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.2,262.10315.167"
  sha256 arm64_linux:  "8ed7c82ad03a8af414458bf1bb42117952c6e60b4781abd201c6ce3fba8d9574",
         x86_64_linux: "d2d7bbc14f1fcb8fa701646d0123f71c521597d2f37072d2072577b803fd041a"

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
  depends_on linux: :any

  binary "rustrover/bin/rustrover"
  artifact "jetbrains-rustrover.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-rustrover.desktop"
  artifact "rustrover/bin/rustrover.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/rustrover.svg"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    move "RustRover-*", "rustrover", source_glob: true
    touch "rustrover/bin/rustrover64.vmoptions"
    inreplace "rustrover/bin/rustrover64.vmoptions", /\z/, "-Dide.no.platform.update=true\n"
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-rustrover.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=RustRover
      Comment=A powerful IDE for Rust
      Exec={{HOMEBREW_PREFIX}}/bin/rustrover %u
      Icon=rustrover
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;rust;
      Terminal=false
      StartupWMClass=jetbrains-rustrover
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
    "#{Dir.home}/.cache/JetBrains/RustRover#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/RustRover#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/RustRover#{version.major_minor}",
  ]
end
