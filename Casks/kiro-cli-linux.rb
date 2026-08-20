cask "kiro-cli-linux" do
  arch arm:   "aarch64",
       intel: "x86_64"

  version "2.19.0"
  sha256 arm64_linux:  "a098f722c71d354de4ef1723930d69e5bbc7096d7a97f0cba77d8d66f2188614",
         x86_64_linux: "51f88c55c5231100049207961fab7e50ed958b80e03c08d825216c8fc08f6170"

  url "https://prod.download.cli.kiro.dev/stable/#{version}/kirocli-#{arch}-linux.zip",
      verified: "prod.download.cli.kiro.dev/"
  name "Kiro CLI"
  desc "Amazon Q Developer CLI - AI-powered command-line assistant"
  homepage "https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html"

  livecheck do
    url "https://prod.download.cli.kiro.dev/stable/latest/manifest.json"
    strategy :json do |json|
      json["version"]
    end
  end

  depends_on linux: :any

  binary "kirocli/bin/kiro-cli"
  binary "kirocli/bin/kiro-cli-chat"
  binary "kirocli/bin/kiro-cli-term"

  postflight do
    # Create `q` symlink for backward compatibility with Amazon Q CLI
    q_link = "#{HOMEBREW_PREFIX}/bin/q"
    FileUtils.rm(q_link, force: true)
    FileUtils.ln_s "#{HOMEBREW_PREFIX}/bin/kiro-cli", q_link
  end

  uninstall_postflight do
    FileUtils.rm("#{HOMEBREW_PREFIX}/bin/q", force: true)
  end

  zap trash: [
    "~/.config/kiro",
    "~/.kiro",
    "~/.local/share/kiro",
  ]
end
