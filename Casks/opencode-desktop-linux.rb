cask "opencode-desktop-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "2.0.30"
  sha256 arm64_linux:  "e8eb5dc8e9710a6c83ba3728bc0066f5d9cbcdb1b5ffd1b62b0ffa32efaecfd3",
         x86_64_linux: "b488a782612d7c61a55698ffd17b012c0a71769f54038322814a6730a580502d"

  # 2.x desktop builds are not on GitHub releases; the anomalyco feed stops at
  # v1.18.32. Filenames are unchanged, so only the host differs.
  url "https://opencode.ai/files/bin/#{version}/opencode-desktop-linux-#{arch}.rpm"
  name "OpenCode"
  desc "Open source AI coding agent desktop client"
  homepage "https://opencode.ai/"

  # The updater endpoint the app itself calls, and the only machine-readable
  # source for 2.x. It returns the newest version whatever version= says, so
  # take both sha256 values from metadata.files here on a bump.
  livecheck do
    url "https://opencode.ai/update/api/latest/desktop/opencode/?arch=x86_64&version=#{version}"
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
