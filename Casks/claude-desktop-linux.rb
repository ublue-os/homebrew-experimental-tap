cask "claude-desktop-linux" do
  version "1.40609.1"
  sha256 "80182e8511c6bbee6de26c7ee225fbd2a9aba2274ef1405a1d89cd8fe7a380dc"

  url "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_#{version}_amd64.deb"
  name "Claude"
  desc "Anthropic's official Claude AI desktop app"
  homepage "https://claude.com/download"

  livecheck do
    url "https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages"
    regex(/^Version: (\d+\.\d+\.\d+)$/m)
  end

  depends_on formula: "dpkg"

  binary "usr/bin/claude-desktop", target: "claude-desktop"
  artifact "usr/share/icons/hicolor/16x16/apps/claude-desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/16x16/apps/claude-desktop.png"
  artifact "usr/share/icons/hicolor/32x32/apps/claude-desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/32x32/apps/claude-desktop.png"
  artifact "usr/share/icons/hicolor/48x48/apps/claude-desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/48x48/apps/claude-desktop.png"
  artifact "usr/share/icons/hicolor/128x128/apps/claude-desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/128x128/apps/claude-desktop.png"
  artifact "usr/share/icons/hicolor/256x256/apps/claude-desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/256x256/apps/claude-desktop.png"
  artifact "usr/share/applications/com.anthropic.Claude.desktop",
           target: "#{Dir.home}/.local/share/applications/com.anthropic.Claude.desktop"

  preflight_steps do
    run "{{HOMEBREW_PREFIX}}/opt/dpkg/bin/dpkg-deb",
        args: ["-x", "{{staged_path}}/claude-desktop_{{version}}_amd64.deb", "{{staged_path}}"]

    inreplace "usr/share/applications/com.anthropic.Claude.desktop", /^Exec=.*/,
              "Exec={{HOMEBREW_PREFIX}}/bin/claude-desktop %U", audit_result: false
    inreplace "usr/share/applications/com.anthropic.Claude.desktop", /^Icon=.*/,
              "Icon=claude-desktop", audit_result: false
  end

  zap trash: [
    "~/.cache/Claude",
    "~/.config/Claude",
    "~/.local/share/Claude",
  ]
end
