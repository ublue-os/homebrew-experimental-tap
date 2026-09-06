cask "jetbrains-gateway-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026.2.2"
  sha256 arm64_linux:  "657455462da422eafead2cecf37999fe8fa17fcce3339cb4d1788d33776b28cd",
         x86_64_linux: "e9eff963201dafc9d16d521459d22c2644774f44a25ac460807d752da9d093a8"

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
