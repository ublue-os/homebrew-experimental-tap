cask "kiro-cli-linux" do
  arch arm:   "aarch64",
       intel: "x86_64"

  version "2.12.2"
  sha256 on_arch_conditional arm:   "b26e466ef6b308a29fe2abfe50c4745b5b805607a58d0df3ba63b4b7993efae8",
                             intel: "224200ace4e059bb69dada23cf78d9dbdd904de40347dfba70ea7897d8e803ca"

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

  binary "kirocli/bin/kiro-cli"
  binary "kirocli/bin/kiro-cli-chat"
  binary "kirocli/bin/kiro-cli-term"

  postflight do
    # Create `q` symlink for backward compatibility with Amazon Q CLI
    q_link = "#{HOMEBREW_PREFIX}/bin/q"
    FileUtils.rm(q_link)
    FileUtils.ln_s "#{HOMEBREW_PREFIX}/bin/kiro-cli", q_link
  end

  uninstall_postflight do
    FileUtils.rm("#{HOMEBREW_PREFIX}/bin/q")
  end

  zap trash: [
    "~/.config/kiro",
    "~/.kiro",
    "~/.local/share/kiro",
  ]
end
