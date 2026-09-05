cask "intellij-idea-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.2.2,262.10315.125"
  sha256 arm64_linux:  "04baba6fb1034aebfbf86e8b55186c818b93dbbbe131012975718ff7f70740f5",
         x86_64_linux: "f1cc5329a7adf3ab3bd8886744103f7d3bcf1ca12e699762ecd9bffe57335f8b"

  url "https://download.jetbrains.com/idea/ideaIU-#{version.csv.first}#{arch}.tar.gz"
  name "IntelliJ IDEA Ultimate"
  desc "Java IDE by JetBrains"
  homepage "https://www.jetbrains.com/idea/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=IIU&latest=true&type=release"
    strategy :json do |json|
      json["IIU"]&.map do |release|
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

  binary "idea/bin/idea"
  artifact "jetbrains-idea.desktop",
           target: "#{Dir.home}/.local/share/applications/jetbrains-idea.desktop"
  artifact "idea/bin/idea.svg",
           target: "#{Dir.home}/.local/share/icons/hicolor/scalable/apps/idea.svg"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    move "idea-IU-*", "idea", source_glob: true
    touch "idea/bin/idea64.vmoptions"
    inreplace "idea/bin/idea64.vmoptions", /\z/, "-Dide.no.platform.update=true\n"
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/scalable/apps", base: :home
    write_file "jetbrains-idea.desktop", <<~EOS
      [Desktop Entry]
      Version=1.0
      Name=Intellij IDEA
      Comment=The IDE for pro Java and Kotlin development
      Exec={{HOMEBREW_PREFIX}}/bin/idea %u
      Icon=idea
      Type=Application
      Categories=Development;IDE;
      Keywords=jetbrains;ide;java;groovy;kotlin;scala;
      Terminal=false
      StartupWMClass=jetbrains-idea
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
    "#{Dir.home}/.cache/JetBrains/IntelliJIdea#{version.major_minor}",
    "#{Dir.home}/.config/JetBrains/IntelliJIdea#{version.major_minor}",
    "#{Dir.home}/.local/share/JetBrains/IntelliJIdea#{version.major_minor}",
  ]
end
