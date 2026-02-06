cask "zed-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "0.220.6"
  sha256 arm64_linux:  "fa8e7eeeaf6e7349349af885c306a8e9839cf55c591d6c2cf896963dffbddfb3",
         x86_64_linux: "0787d8afa066348d06173482f553d9d4213b6a7bed9509675644f50e99768489"

  url "https://github.com/zed-industries/zed/releases/download/v#{version}/zed-linux-#{arch}.tar.gz",
      verified: "github.com/zed-industries/zed/"
  name "Zed"
  desc "High-performance, multiplayer code editor"
  homepage "https://zed.dev/"

  livecheck do
    url "https://api.github.com/repos/zed-industries/zed/releases/latest"
    strategy :json do |json|
      json["tag_name"]&.delete_prefix("v")
    end
  end

  binary "zed.app/bin/zed", target: "zeditor"
  artifact "zed.app/libexec/zed-editor",
           target: "#{HOMEBREW_PREFIX}/opt/zed-linux/libexec/zed-editor"
  artifact "zed.app/lib",
           target: "#{HOMEBREW_PREFIX}/opt/zed-linux/lib"
  artifact "zed.app/share/icons/hicolor/512x512/apps/zed.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/512x512/apps/zed.png"
  artifact "zed.app/share/icons/hicolor/1024x1024/apps/zed.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/1024x1024/apps/zed.png"
  artifact "zed.desktop",
           target: "#{Dir.home}/.local/share/applications/zed.desktop"

  preflight do
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/512x512/apps"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/1024x1024/apps"

    File.write("#{staged_path}/zed.desktop", <<~EOS)
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=Zed
      GenericName=Text Editor
      Comment=A high-performance, multiplayer code editor.
      StartupNotify=true
      Exec=#{HOMEBREW_PREFIX}/bin/zeditor %U
      Icon=#{Dir.home}/.local/share/icons/hicolor/512x512/apps/zed.png
      Categories=Utility;TextEditor;Development;IDE;
      Keywords=zed;
      MimeType=text/plain;application/x-zerosize;x-scheme-handler/zed;
      Actions=NewWorkspace;

      [Desktop Action NewWorkspace]
      Exec=#{HOMEBREW_PREFIX}/bin/zeditor --new %U
      Name=Open a new workspace
    EOS
  end

  postflight do
    # Update desktop database if available
    if system("which update-desktop-database > /dev/null 2>&1")
      system "update-desktop-database", "#{Dir.home}/.local/share/applications"
    end

    # Update icon cache if available
    if system("which gtk-update-icon-cache > /dev/null 2>&1")
      system "gtk-update-icon-cache", "#{Dir.home}/.local/share/icons/hicolor", "-f", "-t"
    end
  end

  uninstall_postflight do
    # Clean up desktop file
    FileUtils.rm("#{Dir.home}/.local/share/applications/zed.desktop")

    # Clean up icons
    FileUtils.rm("#{Dir.home}/.local/share/icons/hicolor/512x512/apps/zed.png")
    FileUtils.rm("#{Dir.home}/.local/share/icons/hicolor/1024x1024/apps/zed.png")

    # Update caches
    if system("which update-desktop-database > /dev/null 2>&1")
      system "update-desktop-database", "#{Dir.home}/.local/share/applications"
    end

    if system("which gtk-update-icon-cache > /dev/null 2>&1")
      system "gtk-update-icon-cache", "#{Dir.home}/.local/share/icons/hicolor", "-f", "-t"
    end
  end

  zap trash: [
    "~/.config/zed",
    "~/.local/share/zed",
  ]
end
