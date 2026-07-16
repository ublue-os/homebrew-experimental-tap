cask "devpod-linux" do
  version "0.6.15"
  sha256 "eb8bfefc4f2c3f20bce370877e985fcc750858f7f06a5db06cfe339cd1eca9ba"

  url "https://github.com/loft-sh/devpod/releases/download/v#{version}/DevPod_linux_amd64.AppImage",
      verified: "github.com/loft-sh/devpod/"
  name "DevPod"
  desc "Reproducible developer environments using dev containers"
  homepage "https://devpod.sh/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "squashfs"

  binary "squashfs-root/AppRun", target: "devpod"

  preflight do
    appimage_path = "#{staged_path}/DevPod_linux_amd64.AppImage"
    system "chmod", "+x", appimage_path
    system appimage_path, "--appimage-extract", chdir: staged_path
    FileUtils.rm appimage_path
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/512x512/apps"

    icon_source = "#{staged_path}/squashfs-root/devpod.png"
    icon_target = "#{xdg_data}/icons/hicolor/512x512/apps/devpod.png"
    FileUtils.cp(icon_source, icon_target) if File.exist?(icon_source)

    File.write("#{xdg_data}/applications/devpod.desktop", <<~EOS)
      [Desktop Entry]
      Name=DevPod
      Comment=Reproducible developer environments using dev containers
      GenericName=Dev Container Tool
      Exec=#{HOMEBREW_PREFIX}/bin/devpod
      Icon=#{icon_target}
      Type=Application
      StartupNotify=true
      StartupWMClass=DevPod
      Categories=Development;IDE;
      Keywords=devcontainer;container;remote;development;
    EOS
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm_f "#{xdg_data}/applications/devpod.desktop"
    FileUtils.rm_f "#{xdg_data}/icons/hicolor/512x512/apps/devpod.png"
  end

  zap trash: [
    "~/.devpod",
    "~/.config/devpod",
  ]
end
