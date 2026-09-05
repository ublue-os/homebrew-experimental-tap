cask "winboat" do
  arch arm: "arm64", intel: "x64"
  os linux: "linux"

  version "0.9.2"
  sha256 "aa5a6ae3e28367dce234d146d4866cea02ae840713b65d8d7456eb277a4e8c98"

  url "https://github.com/TibixDev/winboat/releases/download/v#{version}/winboat-#{version}-x64.tar.gz"
  name "Winboat"
  desc "Run Windows apps on Linux with seamless integration"
  homepage "https://www.winboat.app/"

  livecheck do
    url :url
    strategy :github_latest
  end

  binary "winboat-#{version}-x64/winboat"

  preflight_steps do
    # Download the icon into staged_path, then install it and the desktop entry
    # under the user's data home. `open-uri` is replaced by an explicit curl with
    # `network_access: true`, preserving fail-fast download semantics.
    run "curl",
        args: [
          "--fail", "--location", "--silent", "--show-error", "--output", "winboat.png",
          "https://raw.githubusercontent.com/TibixDev/winboat/main/src/renderer/public/img/winboat_logo.png"
        ],
        chdir: "{{staged_path}}", network_access: true
    copy "winboat.png", ".local/share/icons/hicolor/512x512/apps/winboat.png", target_base: :home
    write_file ".local/share/applications/winboat.desktop", <<~EOS, base: :home
      [Desktop Entry]
      Name=Winboat
      Comment=Run Windows apps on Linux with seamless integration
      Exec={{HOMEBREW_PREFIX}}/bin/winboat %U
      Terminal=false
      Type=Application
      Icon=winboat
      Categories=Utility;
    EOS
  end

  zap trash: [
    "~/.config/winboat",
    "~/.local/share/applications/winboat.desktop",
    "~/.local/share/icons/hicolor/512x512/apps/winboat.png",
    "~/.local/share/winboat",
  ]

  caveats do
    <<~EOS
      Winboat requires the following dependencies to be installed:
        - Docker (for running Windows containers)
        - FreeRDP (for remote desktop protocol support)
      You can install FreeRDP from flatpak:
        flatpak install com.freerdp.FreeRDP
    EOS
  end
end
