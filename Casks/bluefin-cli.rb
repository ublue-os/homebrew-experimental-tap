cask "bluefin-cli" do
  version "0.0.3"

  on_arm do
    on_linux do
      sha256 "1fdad74c832806613613a0111d9ffd465bd3bfd9aa95595ac03378712f877917"
      url "https://github.com/hanthor/bluefin-cli/releases/download/v#{version}/bluefin-cli_#{version}_linux_arm64.tar.gz"
    end
    on_macos do
      sha256 "ef6947d4239740ddf9aee73cfe28c1dfea43ee643ec3745b457e1e7889f7832c"
      url "https://github.com/hanthor/bluefin-cli/releases/download/v#{version}/bluefin-cli_#{version}_darwin_arm64.tar.gz"
    end
  end
  on_intel do
    on_linux do
      sha256 "f6db1ea6bf99fbf94ca8e30ba08175d2e69ba86765a88fccca8b0d3a73985b3a"
      url "https://github.com/hanthor/bluefin-cli/releases/download/v#{version}/bluefin-cli_#{version}_linux_amd64.tar.gz"
    end
    on_macos do
      sha256 "21b064950b96fb5f60db5b5ed4dd764115bbb35c61c6a3c292e6bb7bcf99df2c"
      url "https://github.com/hanthor/bluefin-cli/releases/download/v#{version}/bluefin-cli_#{version}_darwin_amd64.tar.gz"
    end
  end

  name "Bluefin CLI"
  desc "Bluefin's CLI tool"
  homepage "https://github.com/hanthor/bluefin-cli"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  binary "bluefin-cli"
end
