cask "intellij-idea-linux" do
  arch arm: "-aarch64"
  os linux: "linux"

  version "2026.3.0.1,263.7307.353"
  sha256 arm64_linux:  "72cd5618cece2d06e4cfa6fb4b692fcdc7e6d59aaf811e67e9ba4871e02495b6",
         x86_64_linux: "def869cc0109273f5a144ac669c739029e9bd5178d137213b8d15298c0055858"

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
    remove "idea", recursive: true
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
