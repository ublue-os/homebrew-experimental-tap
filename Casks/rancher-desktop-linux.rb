cask "rancher-desktop-linux" do
  version :latest
  sha256 :no_check

  url "https://download.opensuse.org/repositories/isv:/Rancher:/stable/AppImage/rancher-desktop-latest-x86_64.AppImage"
  name "Rancher Desktop"
  desc "Container management and Kubernetes on the desktop"
  homepage "https://rancherdesktop.io/"

  depends_on formula: "squashfs"

  binary "squashfs-root/AppRun", target: "rancher-desktop"

  preflight_steps do
    # Normalise the AppImage filename before extraction.
    move "rancher-desktop-latest-x86_64.AppImage", "rancher-desktop.AppImage"
    set_permissions "rancher-desktop.AppImage", "+x"
    run "rancher-desktop.AppImage", args: ["--appimage-extract"], base: :staged_path, chdir: "{{staged_path}}"
    remove "rancher-desktop.AppImage"
  end

  postflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/512x512/apps", base: :home

    if_path_exists "squashfs-root/rancher-desktop.png" do
      copy "squashfs-root/rancher-desktop.png", ".local/share/icons/hicolor/512x512/apps/rancher-desktop.png",
           target_base: :home
    end

    if_path_exists "squashfs-root/rancher-desktop.desktop" do
      copy "squashfs-root/rancher-desktop.desktop", ".local/share/applications/rancher-desktop.desktop",
           target_base: :home
      inreplace ".local/share/applications/rancher-desktop.desktop", /^Exec=.*/,
                "Exec={{HOMEBREW_PREFIX}}/bin/rancher-desktop", base: :home, audit_result: false
      inreplace ".local/share/applications/rancher-desktop.desktop", /^Icon=.*/, "Icon=rancher-desktop",
                base: :home, audit_result: false
    end
  end

  uninstall_postflight_steps do
    remove ".local/share/icons/hicolor/512x512/apps/rancher-desktop.png", base: :home
    remove ".local/share/applications/rancher-desktop.desktop", base: :home
  end

  zap trash: [
    "~/.config/rancher-desktop",
    "~/.local/share/rancher-desktop",
  ]
end
