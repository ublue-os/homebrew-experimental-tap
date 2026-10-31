cask "jetbrains-gateway-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026.2.4"
  sha256 arm64_linux:  "b2b19670e6cc212bfa538cb37fffa34f42b809f05a51bda39d7b4f99390c5e1b",
         x86_64_linux: "d72034ab3bcc2b9d9d0568b6f57f2ac72fc8632d75d74aa6f89995e8a3f36dcf"

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
