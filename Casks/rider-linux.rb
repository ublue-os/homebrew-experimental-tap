cask "rider-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.3.1,262.10968.170"
  sha256 arm64_linux:  "8239c1e7c0352a9fb79dcbf68fb9550d64b215606a635ed88981291d92995a61",
         x86_64_linux: "fa4b09a5f7cf4b6635b093adc7313991778a8dc74f25614a2b8976b04dee5d4e"

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
    remove "rider", recursive: true
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
