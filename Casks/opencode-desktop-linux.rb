cask "opencode-desktop-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.1.12"
  sha256 arm64_linux:  "cb5a6a9888d4d5fa979eded94b9588428a3fc3bb19052ee4020c25f1ff2ae775",
         x86_64_linux: "632ac2a71875faa3832e5b06fb03a5c0b4edf7f3e4f5c8338086e89f6b8d9c40"

  url "https://github.com/anomalyco/opencode/releases/download/v#{version}/opencode-desktop-linux-#{arch}.rpm",
      verified: "github.com/anomalyco/opencode/"
  name "OpenCode"
  desc "Open source AI coding agent desktop client"
  homepage "https://opencode.ai/"

  livecheck do
    url "https://github.com/anomalyco/opencode/releases/latest/download/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  auto_updates true
  depends_on formula: "rpm2cpio"

  binary "usr/bin/OpenCode", target: "opencode-desktop"
  binary "usr/bin/opencode-cli", target: "opencode-cli"
  artifact "usr/share/icons/hicolor/32x32/apps/OpenCode.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/32x32/apps/OpenCode.png"
  artifact "usr/share/icons/hicolor/128x128/apps/OpenCode.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/128x128/apps/OpenCode.png"
  artifact "usr/share/icons/hicolor/256x256@2/apps/OpenCode.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/256x256@2/apps/OpenCode.png"
  artifact "OpenCode.desktop",
           target: "#{Dir.home}/.local/share/applications/OpenCode.desktop"

  preflight do
    system "sh", "-c", "rpm2cpio '#{staged_path}/opencode-desktop-linux-#{arch}.rpm' | cpio -idm --quiet",
           chdir: staged_path

    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons"

    File.write("#{staged_path}/OpenCode.desktop", <<~EOS)
      [Desktop Entry]
      Name=OpenCode
      Comment=The open source AI coding agent desktop client
      Exec=#{HOMEBREW_PREFIX}/bin/opencode-desktop %U
      Icon=#{Dir.home}/.local/share/icons/hicolor/256x256@2/apps/OpenCode.png
      Terminal=false
      Type=Application
      Categories=Development;
      MimeType=x-scheme-handler/opencode;
      StartupWMClass=OpenCode
    EOS
  end

  zap trash: [
    "~/.cache/ai.opencode.desktop",
    "~/.config/ai.opencode.desktop",
    "~/.local/share/ai.opencode.desktop",
  ]
end
