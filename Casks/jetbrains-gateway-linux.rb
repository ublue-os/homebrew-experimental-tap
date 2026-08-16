cask "jetbrains-gateway-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026.2.1"
  sha256 arm64_linux:  "4b145192467e729641b56073a6275ccdd4f117b640479d43a6d1f2f74baabcda",
         x86_64_linux: "5a3d333acc54ab8d091dc3e635b069a4ddda3faf7dace84966df87cdc7b8fce3"

  url "https://download.jetbrains.com/idea/gateway/JetBrainsGateway-#{version}#{"-aarch64" if arch == "aarch64"}.tar.gz",
      verified: "download.jetbrains.com/idea/gateway/"
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

  binary "JetBrainsGateway-#{version}/bin/gateway.sh", target: "jetbrains-gateway"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/128x128/apps"
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")

    icon_source = "#{staged_path}/JetBrainsGateway-#{version}/bin/gateway.png"
    icon_target = "#{xdg_data}/icons/hicolor/128x128/apps/jetbrains-gateway.png"
    FileUtils.cp(icon_source, icon_target) if File.exist?(icon_source)

    File.write("#{xdg_data}/applications/jetbrains-gateway.desktop", <<~EOS)
      [Desktop Entry]
      Name=JetBrains Gateway
      Comment=Connect to remote development environments with JetBrains IDEs
      GenericName=Remote Development Client
      Exec=#{HOMEBREW_PREFIX}/bin/jetbrains-gateway
      Icon=#{icon_target}
      Type=Application
      StartupNotify=true
      StartupWMClass=jetbrains-gateway
      Categories=Development;IDE;
      Keywords=jetbrains;gateway;remote;development;ssh;
    EOS
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm("#{xdg_data}/applications/jetbrains-gateway.desktop", force: true)
    FileUtils.rm("#{xdg_data}/icons/hicolor/128x128/apps/jetbrains-gateway.png", force: true)
  end

  zap trash: [
    "~/.config/JetBrains/JetBrainsGateway*",
    "~/.local/share/JetBrains/JetBrainsGateway*",
  ]
end
