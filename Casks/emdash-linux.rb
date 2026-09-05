cask "emdash-linux" do
  version "1.2.3"
  sha256 "726c2524e7bfb8eee71b5eb44ac32d6a7031f11a3c0f33545baf8606cd728ef4"

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
