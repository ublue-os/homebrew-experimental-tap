cask "claude-desktop-linux" do
  version "1.32352.0"
  sha256 "2440d074376553d70b22fc1e53347da60e58757498965efeb9899887da61e0d9"

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

  preflight do
    system "#{formula_opt_bin("dpkg")}/dpkg-deb", "-x",
           "#{staged_path}/claude-desktop_#{version}_amd64.deb", staged_path

    desktop_file = "#{staged_path}/usr/share/applications/com.anthropic.Claude.desktop"
    content = File.read(desktop_file)
    content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/claude-desktop %U")
    content.gsub!(/^Icon=.*/, "Icon=#{Dir.home}/.local/share/icons/hicolor/256x256/apps/claude-desktop.png")
    File.write(desktop_file, content)
  end

  zap trash: [
    "~/.cache/Claude",
    "~/.config/Claude",
    "~/.local/share/Claude",
  ]
end
