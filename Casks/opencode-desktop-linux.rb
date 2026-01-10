cask "opencode-desktop-linux" do
  arch arm: "aarch64", intel: "amd64"

  version "1.1.12"
  sha256 arm64_linux:  "9818c5b730697d0229b2c133dc7105730320903438d3cdeb970c64d5ffb9a1ee",
         x86_64_linux: "d886948756b7cbb73d54bb885459296c9547983aa843bde5ed3d858c46ce4a3b"

  url "https://github.com/anomalyco/opencode/releases/download/v#{version}/opencode-desktop-linux-#{arch}.AppImage",
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

  depends_on formula: "squashfs"

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
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/32x32/apps"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/128x128/apps"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/256x256@2/apps"

    # Make AppImage executable
    appimage_name = "opencode-desktop-linux-#{arch}.AppImage"
    FileUtils.chmod "+x", "#{staged_path}/#{appimage_name}"

    # Extract AppImage contents
    system "#{staged_path}/#{appimage_name}", "--appimage-extract", chdir: staged_path

    # Copy binaries from extracted AppImage
    FileUtils.mkdir_p "#{staged_path}/usr/bin"
    FileUtils.cp "#{staged_path}/squashfs-root/bin/OpenCode", "#{staged_path}/usr/bin/OpenCode"
    FileUtils.cp "#{staged_path}/squashfs-root/bin/opencode-cli", "#{staged_path}/usr/bin/opencode-cli"

    # Copy icons from extracted AppImage
    FileUtils.mkdir_p "#{staged_path}/usr/share/icons/hicolor/32x32/apps"
    FileUtils.mkdir_p "#{staged_path}/usr/share/icons/hicolor/128x128/apps"
    FileUtils.mkdir_p "#{staged_path}/usr/share/icons/hicolor/256x256@2/apps"
    FileUtils.cp "#{staged_path}/squashfs-root/share/icons/hicolor/32x32/apps/OpenCode.png",
                 "#{staged_path}/usr/share/icons/hicolor/32x32/apps/OpenCode.png"
    FileUtils.cp "#{staged_path}/squashfs-root/share/icons/hicolor/128x128/apps/OpenCode.png",
                 "#{staged_path}/usr/share/icons/hicolor/128x128/apps/OpenCode.png"
    FileUtils.cp "#{staged_path}/squashfs-root/share/icons/hicolor/256x256@2/apps/OpenCode.png",
                 "#{staged_path}/usr/share/icons/hicolor/256x256@2/apps/OpenCode.png"

    # Create desktop entry
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
