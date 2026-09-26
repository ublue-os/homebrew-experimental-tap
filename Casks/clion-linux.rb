cask "clion-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.3,262.10968.117"
  sha256 arm64_linux:  "97db7e50101b63c64f81f8dcf80b14c4ace42cba697a6b091d9bb2237e22ceb0",
         x86_64_linux: "dbb7d298392bbe471153af98f6f3393173da897eaff1c1c79f2eade6e26d3860"

  url "https://download.jetbrains.com/cpp/CLion-#{version.csv.first}#{arch}.tar.gz"
  name "CLion"
  desc "C and C++ IDE"
  homepage "https://www.jetbrains.com/clion/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=CL&latest=true&type=release"
    strategy :json do |json|
      json["CL"]&.map do |release|
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

  binary "clion/bin/clion"
  artifact "jetbrains-clion.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-clion.desktop"
  artifact "clion/bin/clion.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/clion.svg"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    remove "clion", recursive: true
    move "clion-*", "clion", source_glob: true
    touch "clion/bin/clion64.vmoptions"
    inreplace "clion/bin/clion64.vmoptions", /\z/, "-Dide.no.platform.update=true\n"
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-clion.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=CLion
      Comment=A cross-platform C and C++ IDE
      Exec={{HOMEBREW_PREFIX}}/bin/clion %u
      Icon=clion
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;c;c++;
      Terminal=false
      StartupWMClass=jetbrains-clion
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
    "#{Dir.home}/.cache/JetBrains/CLion#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/CLion#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/CLion#{version.major_minor}",
  ]
end
