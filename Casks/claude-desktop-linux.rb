cask "claude-desktop-linux" do
  version :latest
  sha256 "d15bea06b9212eb5687e27107296a7c842204330a0c72a35aee9b29f65e9c15e"

  url "https://downloads.claude.ai/claude-science/latest/linux-x64",
      verified: "downloads.claude.ai/"
  name "Claude"
  desc "AI assistant by Anthropic"
  homepage "https://claude.ai/"

  auto_updates true

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/512x512/apps"

    # The binary is an AppImage
    binary_path = "#{staged_path}/linux-x64"
    system "chmod", "+x", binary_path
    FileUtils.mv binary_path, "#{staged_path}/claude"
    system "#{staged_path}/claude", "--appimage-extract", chdir: staged_path rescue nil
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    binary_src = "#{staged_path}/claude"

    icon_source = Dir.glob("#{staged_path}/squashfs-root/**/*.png").sort_by { |f| -File.size(f) }.first
    icon_target = "#{xdg_data}/icons/hicolor/512x512/apps/claude.png"
    FileUtils.cp(icon_source, icon_target) if icon_source && File.exist?(icon_source)

    File.write("#{xdg_data}/applications/claude.desktop", <<~EOS)
      [Desktop Entry]
      Name=Claude
      Comment=AI assistant by Anthropic
      GenericName=AI Assistant
      Exec=#{binary_src} %U
      Icon=#{icon_target}
      Type=Application
      StartupNotify=true
      StartupWMClass=Claude
      Categories=Utility;Science;
      MimeType=x-scheme-handler/claude;
      Keywords=ai;assistant;anthropic;claude;llm;
    EOS
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm_f "#{xdg_data}/applications/claude.desktop"
    FileUtils.rm_f "#{xdg_data}/icons/hicolor/512x512/apps/claude.png"
  end

  zap trash: [
    "~/.config/Claude",
    "~/.config/claude-desktop",
    "~/.local/share/Claude",
  ]
end
