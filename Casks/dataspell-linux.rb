cask "dataspell-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.1.3,261.26222.84"
  sha256 arm64_linux:  "6dc809598af27e1f6f11fdb18de986114d79f927d944c431122bcb87e3cfa30c",
         x86_64_linux: "e7b131c9d4677c28980908fad57a3fa2628021b299172923a8348eb847648068"

  url "https://download.jetbrains.com/python/dataspell-#{version.csv.first}#{arch}.tar.gz"
  name "DataSpell"
  desc "IDE for Professional Data Scientists"
  homepage "https://www.jetbrains.com/dataspell/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=DS&latest=true&type=release"
    strategy :json do |json|
      json["DS"]&.map do |release|
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

  binary "dataspell/bin/dataspell"
  artifact "jetbrains-dataspell.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-dataspell.desktop"
  artifact "dataspell/bin/dataspell.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/dataspell.svg"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    move "dataspell-*", "dataspell", source_glob: true
    touch "dataspell/bin/dataspell64.vmoptions"
    inreplace "dataspell/bin/dataspell64.vmoptions", /\z/, "-Dide.no.platform.update=true\n"
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-dataspell.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=DataSpell
      Comment=The IDE for data analysis
      Exec={{HOMEBREW_PREFIX}}/bin/dataspell %u
      Icon=dataspell
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;python;r;
      Terminal=false
      StartupWMClass=jetbrains-dataspell
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
    "#{Dir.home}/.cache/JetBrains/DataSpell#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/DataSpell#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/DataSpell#{version.major_minor}",
  ]
end
