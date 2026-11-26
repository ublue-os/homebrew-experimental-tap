cask "lumo-linux" do
  os linux: "linux"

  version "0.5.10"
  sha256 "8a3a9683f3031f1585a27dd83ba1e8de19b563cb4d09b80292da8d7a38208a23"

  url "https://proton.me/download/lumo/linux/#{version}/Lumo-#{version}-1.x86_64.rpm"
  name "Lumo"
  desc "Privacy-first AI assistant from Proton"
  homepage "https://lumo.proton.me/"

  # Same manifest the app's built-in Tauri updater reads
  livecheck do
    url "https://lumo.protondownload.com/desktop/linux/latest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on arch: :x86_64
  depends_on formula: "cpio"
  depends_on formula: "libayatana-appindicator"
  depends_on formula: "patchelf"
  depends_on formula: "rpm2cpio"
  depends_on formula: "webkitgtk"
  depends_on linux: :any

  binary "usr/bin/lumo-desktop"
  artifact "usr/share/applications/lumo.desktop",
           target: "#{Dir.home}/.local/share/applications/lumo.desktop"
  artifact "usr/share/icons/hicolor/32x32/apps/lumo-desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/32x32/apps/lumo-desktop.png"
  artifact "usr/share/icons/hicolor/128x128/apps/lumo-desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/128x128/apps/lumo-desktop.png"
  # Upstream ships the 2x icon under a non-standard `256x256@2` directory
  artifact "usr/share/icons/hicolor/256x256@2/apps/lumo-desktop.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/256x256/apps/lumo-desktop.png"

  preflight_steps do
    run "sh",
        args: [
          "-c",
          "cd '{{staged_path}}' && '{{HOMEBREW_PREFIX}}/bin/rpm2cpio' " \
          "'{{staged_path}}/Lumo-{{version}}-1.x86_64.rpm' | " \
          "'{{HOMEBREW_PREFIX}}/bin/cpio' -idmu --quiet",
        ]
    remove "Lumo-{{version}}-1.x86_64.rpm"
    # The binary links libwebkit2gtk-4.1 and libayatana-appindicator3, which
    # immutable hosts (Bluefin/Aurora) lack. Resolve them, and the GTK/glib
    # stack they need, from Homebrew. RUNPATH rather than an LD_LIBRARY_PATH
    # wrapper so processes the app spawns (xdg-open, browsers) keep system libs.
    run "{{HOMEBREW_PREFIX}}/bin/patchelf",
        args: ["--set-rpath", "{{HOMEBREW_PREFIX}}/lib", "{{staged_path}}/usr/bin/lumo-desktop"]
    inreplace "usr/share/applications/lumo.desktop",
              /^Exec=.*/, "Exec={{HOMEBREW_PREFIX}}/bin/lumo-desktop %u"
  end

  zap trash: [
    "~/.cache/me.proton.lumo-app",
    "~/.config/me.proton.lumo-app",
    "~/.local/share/me.proton.lumo-app",
  ]
end
