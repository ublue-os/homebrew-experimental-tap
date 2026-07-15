cask "jetbrains-gateway-linux" do
  arch arm: "aarch64", intel: "x86_64"

  version "2026.1.3"
  sha256 on_arch_conditional intel: "1e2ce880a1fa8285f535d708fc58f862c091cc359f16f40661268c33dc150c20",
                             arm:   :no_check

  url "https://download.jetbrains.com/idea/gateway/JetBrainsGateway-#{version}#{arch == "aarch64" ? "-aarch64" : ""}.tar.gz",
      verified: "download.jetbrains.com/idea/gateway/"
  name "JetBrains Gateway"
  desc "Connect to remote development environments with JetBrains IDEs"
  homepage "https://www.jetbrains.com/remote-development/gateway/"

  livecheck do
    url "https://data.services.jetbrains.com/products/releases?code=GW&latest=true&type=release"
    regex(/\"version\":\s*\"([^\"]+)\"/i)
    strategy :json do |json|
      json.dig("GW", 0, "version")
    end
  end

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
    FileUtils.rm_f "#{xdg_data}/applications/jetbrains-gateway.desktop"
    FileUtils.rm_f "#{xdg_data}/icons/hicolor/128x128/apps/jetbrains-gateway.png"
  end

  zap trash: [
    "~/.config/JetBrains/JetBrainsGateway*",
    "~/.local/share/JetBrains/JetBrainsGateway*",
  ]
end
