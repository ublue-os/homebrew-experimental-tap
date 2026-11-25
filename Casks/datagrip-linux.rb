cask "datagrip-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.3.0.1,263.7307.336"
  sha256 arm64_linux:  "82b8f067e96e607f90189bc06895901a41956d44fc50dc02d9994c4f284eb4a7",
         x86_64_linux: "58b6a60b791f4e59bb27ec92ed4b09815a72c54862a456749b9633ae687957b7"

  url "https://download.jetbrains.com/datagrip/datagrip-#{version.csv.first}#{arch}.tar.gz"
  name "DataGrip"
  desc "Databases and SQL IDE"
  homepage "https://www.jetbrains.com/datagrip/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=DG&latest=true&type=release"
    strategy :json do |json|
      json["DG"]&.map do |release|
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

  binary "datagrip/bin/datagrip"
  artifact "jetbrains-datagrip.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-datagrip.desktop"
  artifact "datagrip/bin/datagrip.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/datagrip.svg"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    remove "datagrip", recursive: true
    move "DataGrip-*", "datagrip", source_glob: true
    touch "datagrip/bin/datagrip64.vmoptions"
    inreplace "datagrip/bin/datagrip64.vmoptions", /\z/, "-Dide.no.platform.update=true\n"
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-datagrip.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=DataGrip
      Comment=The IDE for databases and SQL
      Exec={{HOMEBREW_PREFIX}}/bin/datagrip %u
      Icon=datagrip
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;database;sql;
      Terminal=false
      StartupWMClass=jetbrains-datagrip
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
    "#{Dir.home}/.cache/JetBrains/DataGrip#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/DataGrip#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/DataGrip#{version.major_minor}",
  ]
end
