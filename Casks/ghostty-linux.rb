cask "ghostty-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "1.3.1"
  sha256 arm64_linux:  "55b7d1e2073b80954e23167a70f9e5994189d81e954d36dad4d2dc2d2fe6c121",
         x86_64_linux: "fde48d2b716afd1978766879bbf1aae30dd305e8ad86a1037a2614a14d82dc28"

  url "https://github.com/pkgforge-dev/ghostty-appimage/releases/download/v#{version}/Ghostty-#{version}-#{arch}.AppImage"
  name "Ghostty"
  desc "Fast, feature-rich, and native terminal emulator"
  homepage "https://ghostty.org/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on linux: :any
  depends_on formula: "squashfs"

  binary "ghostty-wrapper", target: "ghostty"

  preflight_steps do
    # Normalise the arch/version-specific AppImage filename before extraction.
    move "Ghostty-*.AppImage", "ghostty.AppImage", source_glob: true
    set_permissions "ghostty.AppImage", "+x"
    run "ghostty.AppImage", args: ["--appimage-extract"], base: :staged_path,
        chdir: "{{staged_path}}"
    remove "ghostty.AppImage"

    mkdir_p ".local/share/applications", base: :home

    # Create wrapper script to execute AppRun from the correct directory
    # (upstream switched from binary AppRun to shell script in v1.2.3 which
    # breaks symlinks since it uses $0's directory to find resources)
    write_file "ghostty-wrapper", <<~SH
      #!/bin/sh
      exec "{{staged_path}}/squashfs-root/AppRun" "$@"
    SH
    set_permissions "ghostty-wrapper", "0755"
  end

  postflight_steps do
    # keep the app-id filename (GNOME window matching) and the Exec arguments;
    # disable D-Bus activation since the bundled service file execs a CI path
    copy "squashfs-root/com.mitchellh.ghostty.desktop",
         ".local/share/applications/com.mitchellh.ghostty.desktop", target_base: :home
    inreplace ".local/share/applications/com.mitchellh.ghostty.desktop", /^TryExec=\S+/,
              "TryExec={{HOMEBREW_PREFIX}}/bin/ghostty", base: :home, audit_result: false
    inreplace ".local/share/applications/com.mitchellh.ghostty.desktop", /^Exec=\S+/,
              "Exec={{HOMEBREW_PREFIX}}/bin/ghostty", base: :home, audit_result: false
    inreplace ".local/share/applications/com.mitchellh.ghostty.desktop", /^DBusActivatable=true$/,
              "DBusActivatable=false", base: :home, audit_result: false

    # Copy every discovered icon size through a staged handle onto the narrowly
    # writable hicolor tree, mirroring the original per-size loop.
    mkdir_p ".local/share/icons/hicolor", base: :home
    mkdir_p "ghostty-user-data"
    symlink ".local/share", "ghostty-user-data/share", source_base: :home, overwrite: true
    write_file "install-ghostty-icons.sh", <<~SH
      #!/bin/sh
      for icon in "{{staged_path}}"/squashfs-root/share/icons/hicolor/*/apps/com.mitchellh.ghostty.png; do
        [ -f "$icon" ] || continue
        size=$(basename "$(dirname "$(dirname "$icon")")")
        target="{{staged_path}}/ghostty-user-data/share/icons/hicolor/$size/apps"
        mkdir -p "$target"
        cp "$icon" "$target/com.mitchellh.ghostty.png"
      done
    SH
    set_permissions "install-ghostty-icons.sh", "0755"
    run "install-ghostty-icons.sh", base: :staged_path,
                                    writable_paths: [".local/share/icons/hicolor"], writable_base: :home
    run "gtk-update-icon-cache", args: ["-f", "-t", "{{staged_path}}/ghostty-user-data/share/icons/hicolor"],
                                 must_succeed: false,
                                 writable_paths: [".local/share/icons/hicolor"], writable_base: :home

    # clean up files older cask revisions installed under wrong names/locations
    remove ".local/share/applications/ghostty.desktop", base: :home
    remove ".local/share/icons/ghostty.png", base: :home
    remove ".local/share/systemd/user/com.mitchellh.ghostty.service", base: :home
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/com.mitchellh.ghostty.desktop", base: :home
    remove ".local/share/icons/hicolor/*/apps/com.mitchellh.ghostty.png", base: :home
    mkdir_p "ghostty-user-data"
    symlink ".local/share", "ghostty-user-data/share", source_base: :home, overwrite: true
    run "gtk-update-icon-cache", args: ["-f", "-t", "{{staged_path}}/ghostty-user-data/share/icons/hicolor"],
                                 must_succeed: false,
                                 writable_paths: [".local/share/icons/hicolor"], writable_base: :home
    # leftovers from cask revisions that installed under the wrong names
    remove ".local/share/applications/ghostty.desktop", base: :home
    remove ".local/share/icons/ghostty.png", base: :home
    remove ".local/share/systemd/user/com.mitchellh.ghostty.service", base: :home
  end

  zap trash: "~/.config/ghostty"
end
