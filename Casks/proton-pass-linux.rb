cask "proton-pass-linux" do
  version "1.40.0"
  sha256 "dfa698d4a724c2477248286df925148ce4c0b8f783073ee51d17dea4cab7dd4c"

  url "https://proton.me/download/pass/linux/proton-pass-#{version}-1.x86_64.rpm"
  name "Proton Pass"
  desc "Open-source, end-to-end encrypted password manager"
  homepage "https://proton.me/pass"

  livecheck do
    url "https://proton.me/download/PassDesktop/linux/version.json"
    strategy :json do |json|
      json["Releases"]&.find { |r| r["CategoryName"] == "Stable" }&.dig("Version")
    end
  end

  auto_updates true
  depends_on linux: :any
  depends_on arch: :x86_64
  depends_on formula: "cpio"
  depends_on formula: "rpm2cpio"

  binary "usr/lib/proton-pass/Proton Pass", target: "proton-pass"
  artifact "usr/share/applications/proton-pass.desktop",
           target: "#{Dir.home}/.local/share/applications/proton-pass.desktop"
  artifact "usr/share/pixmaps/proton-pass.png",
           target: "#{Dir.home}/.local/share/pixmaps/proton-pass.png"
  artifact "usr/lib/proton-pass/resources/assets/icon.png",
           target: "#{Dir.home}/.local/share/icons/hicolor/512x512/apps/proton-pass.png"

  preflight_steps do
    run "sh",
        args: [
          "-c",
          "cd '{{staged_path}}' && '{{HOMEBREW_PREFIX}}/bin/rpm2cpio' " \
          "'{{staged_path}}/proton-pass-{{version}}-1.x86_64.rpm' | " \
          "'{{HOMEBREW_PREFIX}}/bin/cpio' -idmu --quiet",
        ]
    remove "proton-pass-{{version}}-1.x86_64.rpm"
    inreplace "usr/share/applications/proton-pass.desktop",
              /^Exec=.*/, "Exec={{HOMEBREW_PREFIX}}/bin/proton-pass %U"
  end

  zap trash: [
    "~/.cache/Proton Pass",
    "~/.cache/proton-pass",
    "~/.cache/protonpass",
    "~/.config/Proton Pass",
    "~/.config/proton-pass",
    "~/.config/protonpass",
    "~/.local/share/proton-pass",
  ]
end
