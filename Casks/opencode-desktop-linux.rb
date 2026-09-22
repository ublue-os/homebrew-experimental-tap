cask "opencode-desktop-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.18.32"
  sha256 arm64_linux:  "f7b70202d8e6a22253640861bf4c06bcefdfac7bc3f3ec338dcd4364a7c1d8c2",
         x86_64_linux: "f585ec22b63cc5c1a06ec6d8af576e180135ec036eb024c0abe45c14f9904ca7"

  url "https://github.com/anomalyco/opencode/releases/download/v#{version}/opencode-desktop-linux-#{arch}.rpm"
  name "OpenCode"
  desc "Open source AI coding agent desktop client"
  homepage "https://opencode.ai/"

  livecheck do
    url "https://github.com/anomalyco/opencode/releases/latest/download/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on formula: "cpio"
  depends_on formula: "gtk+3"
  depends_on formula: "rpm2cpio"
  depends_on linux: :any

  binary "opt/OpenCode/ai.opencode.desktop", target: "opencode-desktop"
  artifact "usr/share/applications/opencode-desktop.desktop",
           target: "#{Dir.home}/.local/share/applications/opencode-desktop.desktop"
  artifact "usr/share/applications/ai.opencode.desktop.desktop",
           target: "#{Dir.home}/.local/share/applications/ai.opencode.desktop.desktop"
  artifact "usr/share/icons/hicolor/32x32/apps/ai.opencode.desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/32x32/apps/ai.opencode.desktop.png"
  artifact "usr/share/icons/hicolor/64x64/apps/ai.opencode.desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/64x64/apps/ai.opencode.desktop.png"
  artifact "usr/share/icons/hicolor/128x128/apps/ai.opencode.desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/128x128/apps/ai.opencode.desktop.png"

  preflight_steps do
    # Normalise the arch-specific RPM filename, then split extraction.
    move "opencode-desktop-linux-*.rpm", "opencode-desktop.rpm", source_glob: true
    run "{{HOMEBREW_PREFIX}}/bin/rpm2cpio", args:        ["{{staged_path}}/opencode-desktop.rpm"],
                                            stdout_path: "opencode-desktop.cpio"
    run "{{HOMEBREW_PREFIX}}/bin/cpio", args: ["-idm", "--quiet"], stdin_path: "opencode-desktop.cpio",
        chdir: "{{staged_path}}"
    remove ["opencode-desktop.rpm", "opencode-desktop.cpio"]

    # Rewrite every discovered desktop file, mirroring the original
    # `Dir["#{staged_path}/usr/share/applications/*.desktop"].each` behaviour.
    run "sh", args: ["-c", <<~SH]
      for f in "{{staged_path}}"/usr/share/applications/*.desktop; do
        [ -f "$f" ] || continue
        sed -i 's#^Exec=.*#Exec={{HOMEBREW_PREFIX}}/bin/opencode-desktop %U#' "$f"
      done
    SH
  end

  zap trash: [
    "~/.cache/ai.opencode.desktop",
    "~/.config/ai.opencode.desktop",
    "~/.local/share/ai.opencode.desktop",
  ]
end
