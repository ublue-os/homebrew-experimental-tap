cask "cursor-linux" do
  arch arm: "arm64", intel: "x64"
  file_arch = on_arch_conditional arm: "aarch64", intel: "x86_64"

  version "2.1.44,f6a8593b2b7c61c2063c79d5a8fcd248c9db458a"
  sha256 arm64_linux:  "bd93a1a0142637f9f1d9cab1eaf1f8330f4002daf15f35506004f0c8bed83ef7",
         x86_64_linux: "2543647505ffcf94ebc832bc69e0b54050037462e959b79e9aa02b9a731e5d0a"

  url "https://downloads.cursor.com/production/#{version.csv.second}/linux/#{arch}/Cursor-#{version.csv.first}-#{file_arch}.AppImage",
      verified: "downloads.cursor.com/"
  name "Cursor"
  desc "Write, edit, and chat about your code with AI"
  homepage "https://www.cursor.com/"

  livecheck do
    url "https://api2.cursor.sh/updates/api/update/linux-x64/cursor/0.0.0/stable"
    regex(%r{/production/(\h+)/linux/x64/Cursor[._-]([0-9.]+)[._-]x86_64\.AppImage}i)
    strategy :json do |json, regex|
      match = json["url"]&.match(regex)
      next if match.blank?

      "#{json["version"]},#{match[1]}"
    end
  end

  binary "Cursor-#{version.csv.first}-#{file_arch}.AppImage", target: "cursor"
  bash_completion "#{staged_path}/squashfs-root/usr/share/cursor/resources/completions/bash/cursor"
  zsh_completion  "#{staged_path}/squashfs-root/usr/share/cursor/resources/completions/zsh/_cursor"
  artifact "cursor.desktop",
           target: "#{Dir.home}/.local/share/applications/cursor.desktop"
  artifact "cursor.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/512x512/apps/cursor.png"

  preflight do
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/512x512/apps"

    # Make AppImage executable
    appimage_name = "Cursor-#{version.csv.first}-#{file_arch}.AppImage"
    FileUtils.chmod "+x", "#{staged_path}/#{appimage_name}"

    # Extract AppImage contents to get resources (icon, completions, etc.)
    system "#{staged_path}/#{appimage_name}", "--appimage-extract", chdir: staged_path

    # Copy icon from extracted AppImage
    icon_source = "#{staged_path}/squashfs-root/usr/share/icons/hicolor/512x512/apps/cursor.png"
    FileUtils.cp icon_source, "#{staged_path}/cursor.png" if File.exist?(icon_source)

    File.write("#{staged_path}/cursor.desktop", <<~EOS)
      [Desktop Entry]
      Name=Cursor
      Comment=AI-first coding environment
      GenericName=Text Editor
      Exec=#{HOMEBREW_PREFIX}/bin/cursor %F
      Icon=#{Dir.home}/.local/share/icons/hicolor/512x512/apps/cursor.png
      Type=Application
      StartupNotify=false
      StartupWMClass=Cursor
      Categories=TextEditor;Development;IDE;
      MimeType=text/plain;inode/directory;application/x-code-workspace;
      Actions=new-empty-window;
      Keywords=cursor;code;editor;

      [Desktop Action new-empty-window]
      Name=New Empty Window
      Exec=#{HOMEBREW_PREFIX}/bin/cursor --new-window %F
      Icon=#{Dir.home}/.local/share/icons/hicolor/512x512/apps/cursor.png
    EOS

    # Create a placeholder icon if extraction fails
    FileUtils.touch "#{staged_path}/cursor.png" unless File.exist?("#{staged_path}/cursor.png")
  end

  zap trash: [
    "~/.config/Cursor",
    "~/.cursor",
  ]
end
