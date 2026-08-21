cask "opencode-desktop-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.18.19"
  sha256 arm64_linux:  "ece94c2f8a91ecd68d53d7064be42581c983f096dae2782223147b667b9f5b37",
         x86_64_linux: "a921d2cc78dd8757996277133d752c89474720dd08b3e393b6fa62ce0e7e6666"

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

  depends_on linux: :any
  depends_on formula: "gtk+3"
  depends_on formula: "rpm2cpio"
  depends_on formula: "cpio"

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

  preflight do
    rpm2cpio = Formula["rpm2cpio"].bin/"rpm2cpio"
    cpio = Formula["cpio"].bin/"cpio"
    system "sh", "-c", "'#{rpm2cpio}' '#{staged_path}/opencode-desktop-linux-#{arch}.rpm' | '#{cpio}' -idm --quiet",
           chdir: staged_path

    # Update desktop files to use Homebrew binary path
    desktop_files = Dir["#{staged_path}/usr/share/applications/*.desktop"]
    desktop_files.each do |desktop_file|
      content = File.read(desktop_file)
      content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/opencode-desktop %U")
      File.write(desktop_file, content)
    end
  end

  zap trash: [
    "~/.cache/ai.opencode.desktop",
    "~/.config/ai.opencode.desktop",
    "~/.local/share/ai.opencode.desktop",
  ]
end
