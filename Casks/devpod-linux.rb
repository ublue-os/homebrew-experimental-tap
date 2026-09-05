cask "devpod-linux" do
  version "0.6.15"
  sha256 "eb8bfefc4f2c3f20bce370877e985fcc750858f7f06a5db06cfe339cd1eca9ba"

  url "https://github.com/loft-sh/devpod/releases/download/v#{version}/DevPod_linux_amd64.AppImage"
  name "DevPod"
  desc "Reproducible developer environments using dev containers"
  homepage "https://devpod.sh/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "squashfs"

  binary "squashfs-root/AppRun", target: "devpod"

  preflight_steps do
    # Normalise the AppImage filename before extraction.
    move "DevPod_linux_amd64.AppImage", "devpod.AppImage"
    set_permissions "devpod.AppImage", "+x"
    run "devpod.AppImage", args: ["--appimage-extract"], base: :staged_path, chdir: "{{staged_path}}"
    remove "devpod.AppImage"
  end

  postflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/512x512/apps", base: :home

    if_path_exists "squashfs-root/devpod.png" do
      copy "squashfs-root/devpod.png", ".local/share/icons/hicolor/512x512/apps/devpod.png",
           target_base: :home
    end

    write_file ".local/share/applications/devpod.desktop", <<~EOS, base: :home
      [Desktop Entry]
      Name=DevPod
      Comment=Reproducible developer environments using dev containers
      GenericName=Dev Container Tool
      Exec={{HOMEBREW_PREFIX}}/bin/devpod
      Icon=devpod
      Type=Application
      StartupNotify=true
      StartupWMClass=DevPod
      Categories=Development;IDE;
      Keywords=devcontainer;container;remote;development;
    EOS
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/devpod.desktop", base: :home
    remove ".local/share/icons/hicolor/512x512/apps/devpod.png", base: :home
  end

  zap trash: [
    "~/.config/devpod",
    "~/.devpod",
  ]
end
