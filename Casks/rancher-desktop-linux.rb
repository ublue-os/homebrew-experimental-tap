cask "rancher-desktop-linux" do
  version :latest
  sha256 :no_check

  url "https://download.opensuse.org/repositories/isv:/Rancher:/stable/AppImage/rancher-desktop-latest-x86_64.AppImage"
  name "Rancher Desktop"
  desc "Container management and Kubernetes on the desktop"
  homepage "https://rancherdesktop.io/"

  auto_updates true
  depends_on formula: "squashfs"

  binary "squashfs-root/AppRun", target: "rancher-desktop"

  preflight do
    # Extract AppImage contents
    appimage_path = "#{staged_path}/rancher-desktop-latest-x86_64.AppImage"
    system "chmod", "+x", appimage_path
    system appimage_path, "--appimage-extract", chdir: staged_path

    # Remove the original AppImage to save space
    FileUtils.rm appimage_path
  end

  postflight do
    # Create necessary directories
    FileUtils.mkdir_p "#{Dir.home}/.local/share/applications"
    FileUtils.mkdir_p "#{Dir.home}/.local/share/icons/hicolor/512x512/apps"

    # Copy icon
    icon_source = "#{staged_path}/squashfs-root/rancher-desktop.png"
    icon_target = "#{Dir.home}/.local/share/icons/hicolor/512x512/apps/rancher-desktop.png"
    FileUtils.cp(icon_source, icon_target) if File.exist?(icon_source)

    # Update and copy desktop entry
    desktop_source = "#{staged_path}/squashfs-root/rancher-desktop.desktop"
    desktop_target = "#{Dir.home}/.local/share/applications/rancher-desktop.desktop"
    if File.exist?(desktop_source)
      desktop_content = File.read(desktop_source)
      desktop_content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/rancher-desktop")
      desktop_content.gsub!(/^Icon=.*/, "Icon=#{icon_target}")
      File.write(desktop_target, desktop_content)
    end
  end

  uninstall_postflight do
    # Clean up icon and desktop files
    FileUtils.rm("#{Dir.home}/.local/share/icons/hicolor/512x512/apps/rancher-desktop.png")
    FileUtils.rm("#{Dir.home}/.local/share/applications/rancher-desktop.desktop")
  end

  zap trash: [
    "~/.config/rancher-desktop",
    "~/.local/share/rancher-desktop",
  ]
end
