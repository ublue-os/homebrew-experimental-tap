cask "positron-linux" do
  arch arm: "arm64", intel: "x64"

  version "2026.10.0-297"
  sha256 arm64_linux:  "d3e5f36fba08cf84b435bb42548533e06d68a5e90723e24703efa1fc3988e4ee",
         x86_64_linux: "3353fed8475b489d3c2f2f3bafb7abb9727be3a6385215d4967d0944596b2ea7"

  url "https://cdn.posit.co/positron/releases/deb/#{(arch == "arm64") ? "arm64" : "x86_64"}/Positron-#{version}-#{arch}.deb"
  name "Positron"
  desc "Next-generation data science IDE for R and Python"
  homepage "https://positron.posit.co/"

  livecheck do
    url "https://api.github.com/repos/posit-dev/positron/releases/latest"
    regex(/"tag_name":\s*"([^"]+)"/i)
    strategy :json do |json|
      json["tag_name"]
    end
  end

  depends_on formula: "dpkg"
  depends_on linux: :any

  binary "usr/bin/positron", target: "positron"

  preflight_steps do
    # Normalise the arch- and version-specific deb filename, then extract.
    move "Positron-{{version}}-*.deb", "positron.deb", source_glob: true
    run "{{HOMEBREW_PREFIX}}/opt/dpkg/bin/dpkg-deb",
        args: ["-x", "{{staged_path}}/positron.deb", "{{staged_path}}"]
    remove "positron.deb"
  end

  postflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/256x256/apps", base: :home

    if_path_exists "usr/share/icons/hicolor/256x256/apps/positron.png" do
      copy "usr/share/icons/hicolor/256x256/apps/positron.png",
           ".local/share/icons/hicolor/256x256/apps/positron.png", target_base: :home
    end

    if_path_exists "usr/share/applications/positron.desktop" do
      inreplace "usr/share/applications/positron.desktop", /^Exec=.*/,
                "Exec={{HOMEBREW_PREFIX}}/bin/positron %F", audit_result: false
      inreplace "usr/share/applications/positron.desktop", /^Icon=.*/,
                "Icon=positron", audit_result: false
      copy "usr/share/applications/positron.desktop", ".local/share/applications/positron.desktop",
           target_base: :home
    end
    unless_path_exists "usr/share/applications/positron.desktop" do
      write_file ".local/share/applications/positron.desktop", <<~EOS, base: :home
        [Desktop Entry]
        Name=Positron
        Comment=Next-generation data science IDE for R and Python
        GenericName=Data Science IDE
        Exec={{HOMEBREW_PREFIX}}/bin/positron %F
        Icon=positron
        Type=Application
        StartupNotify=true
        StartupWMClass=Positron
        Categories=Development;IDE;Science;
        MimeType=text/plain;inode/directory;
        Keywords=r;python;data;science;statistics;
      EOS
    end
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/positron.desktop", base: :home
    remove ".local/share/icons/hicolor/256x256/apps/positron.png", base: :home
  end

  zap trash: [
    "~/.config/Positron",
    "~/.local/share/positron",
  ]
end
