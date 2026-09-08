cask "pycharm-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.2,262.10315.174"
  sha256 arm64_linux:  "16ff89b445b91c44680031509efcb97a28ba3fd7b094a0dc47dcdd5daa3541e0",
         x86_64_linux: "60448e3fb4e6a700e3d2ad3583ea8de1505b3f436e6715329a5a35e31c34aced"

  url "https://download.jetbrains.com/python/pycharm-#{version.csv.first}#{arch}.tar.gz"
  name "PyCharm"
  desc "IDE for professional Python development"
  homepage "https://www.jetbrains.com/pycharm/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=PCP&latest=true&type=release"
    strategy :json do |json|
      json["PCP"]&.map do |release|
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

  binary "pycharm/bin/pycharm"
  artifact "jetbrains-pycharm.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-pycharm.desktop"
  artifact "pycharm/bin/pycharm.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/pycharm.svg"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    move "pycharm-*", "pycharm", source_glob: true
    touch "pycharm/bin/pycharm64.vmoptions"
    inreplace "pycharm/bin/pycharm64.vmoptions", /\z/, "-Dide.no.platform.update=true\n"
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-pycharm.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=PyCharm
      Comment=The Only Python IDE you need
      Exec={{HOMEBREW_PREFIX}}/bin/pycharm %u
      Icon=pycharm
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;python;
      Terminal=false
      StartupWMClass=jetbrains-pycharm
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
    "#{Dir.home}/.cache/JetBrains/PyCharm#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/PyCharm#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/PyCharm#{version.major_minor}",
  ]
end
