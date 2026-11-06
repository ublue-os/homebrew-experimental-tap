cask "jetbrains-gateway-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026.3"
  sha256 arm64_linux:  "8423ff6bb1de487a8535c63c76a90905b851c772106a545a92e5b3be5eba02b3",
         x86_64_linux: "440b3961ddff85b3655895e310a691200961a46bb6bc2d711d9031773bdfa2b6"

  url "https://download.jetbrains.com/idea/gateway/JetBrainsGateway-#{version}#{"-aarch64" if arch == "aarch64"}.tar.gz"
  name "JetBrains Gateway"
  desc "Connect to remote development environments with JetBrains IDEs"
  homepage "https://www.jetbrains.com/remote-development/gateway/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=GW&latest=true&type=release"
    regex(/"version":\s*"([^"]+)"/i)
    strategy :json do |json|
      json.dig("GW", 0, "version")
    end
  end

  depends_on linux: :any

  binary "gateway/bin/gateway.sh", target: "jetbrains-gateway"

  preflight_steps do
    # Normalise the versioned directory before referring to it in declarative steps.
    move "JetBrainsGateway-*", "gateway", source_glob: true
    mkdir_p ".local/share/applications", base: :home
    mkdir_p ".local/share/icons/hicolor/128x128/apps", base: :home
  end

  postflight_steps do
    if_path_exists "gateway/bin/gateway.png" do
      copy "gateway/bin/gateway.png", ".local/share/icons/hicolor/128x128/apps/jetbrains-gateway.png",
           target_base: :home
    end

    write_file ".local/share/applications/jetbrains-gateway.desktop", <<~EOS, base: :home
      [Desktop Entry]
      Name=JetBrains Gateway
      Comment=Connect to remote development environments with JetBrains IDEs
      GenericName=Remote Development Client
      Exec={{HOMEBREW_PREFIX}}/bin/jetbrains-gateway
      Icon=jetbrains-gateway
      Type=Application
      StartupNotify=true
      StartupWMClass=jetbrains-gateway
      Categories=Development;IDE;
      Keywords=jetbrains;gateway;remote;development;ssh;
    EOS
  end

  uninstall_postflight_steps do
    remove ".local/share/applications/jetbrains-gateway.desktop", base: :home
    remove ".local/share/icons/hicolor/128x128/apps/jetbrains-gateway.png", base: :home
  end

  zap trash: [
    "~/.config/JetBrains/JetBrainsGateway*",
    "~/.local/share/JetBrains/JetBrainsGateway*",
  ]
end
