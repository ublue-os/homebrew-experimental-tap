cask "zed-linux@preview" do
  version "0.233.1"
  sha256 "7693529112bb477c9aa3f9e09bd20a9d0ce20c2f606d3aef555f4636a564c2c0"

  url "https://zed.dev/api/releases/preview/#{version}/zed-linux-x86_64.tar.gz"
  name "Zed Preview"
  desc "High-performance, multiplayer code editor (preview build)"
  homepage "https://zed.dev/"

  livecheck do
    url "https://zed.dev/api/releases/latest?asset=zed-linux-x86_64.tar.gz&preview=1&os=linux&arch=x86_64"
    strategy :json do |json|
      json["version"]
    end
  end

  binary "zed-preview.app/bin/zed", target: "zed-preview"

  preflight_steps do
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons", base: :home
  end

  postflight_steps do
    copy "zed-preview.app/share/applications/dev.zed.Zed-Preview.desktop",
         ".local/share/applications/dev.zed.Zed-Preview.desktop", target_base: :home
    inreplace ".local/share/applications/dev.zed.Zed-Preview.desktop", /^TryExec=.*/,
              "TryExec={{HOMEBREW_PREFIX}}/bin/zed-preview", base: :home, audit_result: false
    inreplace ".local/share/applications/dev.zed.Zed-Preview.desktop", /^Exec=zed/,
              "Exec={{HOMEBREW_PREFIX}}/bin/zed-preview", base: :home, audit_result: false
    inreplace ".local/share/applications/dev.zed.Zed-Preview.desktop", /^Icon=.*/, "Icon=zed-preview",
              base: :home, audit_result: false
    copy "zed-preview.app/share/icons/hicolor/512x512/apps/zed.png", ".local/share/icons/zed-preview.png",
         target_base: :home
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/dev.zed.Zed-Preview.desktop", base: :home
    remove ".local/share/icons/zed-preview.png", base: :home
  end

  zap trash: [
    "#{ENV.fetch("XDG_CACHE_HOME", "#{Dir.home}/.cache")}/zed",
    "#{ENV.fetch("XDG_CONFIG_HOME", "#{Dir.home}/.config")}/zed",
    "#{ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")}/zed",
  ]
end
