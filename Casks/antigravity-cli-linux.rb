cask "antigravity-cli-linux" do
  folder_arch = on_arch_conditional arm: "arm", intel: "x64"
  file_arch = on_arch_conditional arm: "arm64", intel: "x64"

  version "1.0.0,6695125380890624"
  sha256 on_arch_conditional intel: "884deaaba937d9d299d3e2b44506fdd72429eeaec6c722bba0986a6bbba9061a",
                             arm:   "6aee9287263e3bc9b6c8727da74b44412b6de546f0df82a77441e8589c111908"

  url "https://storage.googleapis.com/antigravity-public/antigravity-cli/#{version.csv.first}-#{version.csv.second}/linux-#{folder_arch}/cli_linux_#{file_arch}.tar.gz",
      verified: "storage.googleapis.com/antigravity-public/antigravity-cli/"
  name "Google Antigravity CLI"
  desc "Terminal interface for Antigravity agents"
  homepage "https://antigravity.google/product/antigravity-cli"

  binary "antigravity", target: "antigravity"
  binary "antigravity", target: "agy"

  zap trash: "~/.gemini/antigravity-cli"
end
