cask "craft-agents-linux" do
  version "0.9.0"
  sha256 "cb69faa6f98db74e42368384b9d84693ba00ccab18f66ebdb8b7af7a1661db0c"

  url "https://github.com/lukilabs/craft-agents-oss/releases/download/v#{version}/Craft-Agents-#{version}-linux-x64.AppImage"
  name "Craft Agents"
  desc "Work with most powerful agents in the world, with the UX they deserve"
  homepage "https://agents.craft.do/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "squashfs"

  binary "squashfs-root/@craft-agentelectron", target: "craft-agents"

  preflight do
    appimage_path = "#{staged_path}/Craft-Agents-#{version}-linux-x64.AppImage"
    system "chmod", "+x", appimage_path
    system appimage_path, "--appimage-extract", chdir: staged_path
    FileUtils.rm(appimage_path)
  end

  postflight do
    icons_dir = "#{Dir.home}/.local/share/icons/hicolor/512x512/apps"
    apps_dir = "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p(icons_dir)
    FileUtils.cp("#{staged_path}/squashfs-root/usr/share/icons/hicolor/512x512/apps/@craft-agentelectron.png",
                 icons_dir)
    FileUtils.cp("#{staged_path}/squashfs-root/@craft-agentelectron.desktop", apps_dir)
    desktop_path = "#{apps_dir}/@craft-agentelectron.desktop"
    if File.exist?(desktop_path)
      content = File.read(desktop_path)
      content.gsub!(/^Exec=AppRun/, "Exec=#{HOMEBREW_PREFIX}/bin/craft-agents")
      content.gsub!(/^Icon=.*/, "Icon=#{icons_dir}/@craft-agentelectron.png")
      content.gsub!(/^StartupWMClass=.*/, "StartupWMClass=@craft-agent/electron")
      File.write(desktop_path, content)
    end
  end

  uninstall_postflight do
    FileUtils.rm("#{Dir.home}/.local/share/icons/hicolor/512x512/apps/@craft-agentelectron.png")
    FileUtils.rm("#{Dir.home}/.local/share/applications/@craft-agentelectron.desktop")
  end

  zap trash: [
    "~/.config/Craft Agents",
    "~/.craft-agent",
  ]
end
