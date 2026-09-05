cask "rider-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.1,262.9437.287"
  sha256 arm64_linux:  "8ac97ca180c1a3d988bdccd608bf52989913e04725eb7a28b625563c8c39174f",
         x86_64_linux: "f7a485d26b133daea3e6ebc1257dd4e55aacbf48ca8b4b47dffaef3e1905ebe2"

  url "https://download.jetbrains.com/rider/JetBrains.Rider-#{version.csv.first}#{arch}.tar.gz"
  name "Rider"
  desc ".NET IDE"
  homepage "https://www.jetbrains.com/rider/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=RD&latest=true&type=release"
    strategy :json do |json|
      json["RD"]&.map do |release|
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

  binary "rider/bin/rider"
  artifact "jetbrains-rider.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-rider.desktop"
  artifact "rider/bin/rider.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/rider.svg"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    move "JetBrains Rider-*", "rider", source_glob: true
    touch "rider/bin/rider64.vmoptions"
    inreplace "rider/bin/rider64.vmoptions", /\z/, "-Dide.no.platform.update=true\n"
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-rider.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=Rider
      Comment=All-in-one IDE for .NET and game development
      Exec={{HOMEBREW_PREFIX}}/bin/rider %u
      Icon=rider
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;c#;f#;dotnet;.net;
      Terminal=false
      StartupWMClass=jetbrains-rider
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
    "#{Dir.home}/.cache/JetBrains/Rider#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/Rider#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/Rider#{version.major_minor}",
  ]
end
