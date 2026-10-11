cask "emdash-linux" do
  version "1.2.8"
  sha256 "cd89738e0bbccc80a7fbf009ddecb2bd1b8c6fd858b14d75b1e4c7c1f2eee7f5"

  url "https://github.com/generalaction/emdash/releases/download/v#{version}/emdash-x86_64.AppImage"
  name "Emdash"
  desc "Agentic development environment for running multiple coding agents in parallel"
  homepage "https://emdash.sh/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "squashfs"

  binary "squashfs-root/emdash", target: "emdash"
  artifact "squashfs-root/usr/share/icons/hicolor/512x512/apps/emdash.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/512x512/apps/emdash.png"
  artifact "squashfs-root/emdash.desktop",
           target: "#{Dir.home}/.local/share/applications/emdash.desktop"

  preflight_steps do
    # Normalise the AppImage filename before extraction.
    move "emdash-x86_64.AppImage", "emdash.AppImage"
    set_permissions "emdash.AppImage", "+x"
    run "emdash.AppImage", args: ["--appimage-extract"], base: :staged_path, chdir: "{{staged_path}}"
    remove "emdash.AppImage"
  end

  postflight_steps do
    inreplace ".local/share/applications/emdash.desktop", /^Exec=AppRun/,
              "Exec={{HOMEBREW_PREFIX}}/bin/emdash", base: :home, audit_result: false
    inreplace ".local/share/applications/emdash.desktop", /^Icon=.*/,
              "Icon=emdash", base: :home, audit_result: false
  end

  uninstall_postflight_steps do
    remove ".local/share/icons/hicolor/512x512/apps/emdash.png", base: :home
    remove ".local/share/applications/emdash.desktop", base: :home
  end

  zap trash: "~/.config/emdash"
end
