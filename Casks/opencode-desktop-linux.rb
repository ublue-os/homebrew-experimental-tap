cask "opencode-desktop-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.18.31"
  sha256 arm64_linux:  "1a2eafae5e9b336bf4d0b867a75f1b78617b717401d543ec62c29a0787e880da",
         x86_64_linux: "89bc7028ac0f9e8c62e9ddf6566bbe4f6cbb9648c5438fbb8e550646406e1c4f"

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
