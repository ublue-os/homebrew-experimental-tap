cask "kiro-cli-linux" do
  arch arm:   "aarch64",
       intel: "x86_64"

  version "2.21.2"
  sha256 arm64_linux:  "b3e2d94a5cbb5346abeb7b1f7bc63c3a1d825429e639fa07b127c48de6cdeea3",
         x86_64_linux: "e0a841103aaca507c4a62f734639de47284398ff1c4abd725d3e9045024df4e6"

  url "https://prod.download.cli.kiro.dev/stable/#{version}/kirocli-#{arch}-linux.zip"
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

  postflight_steps do
    # Create `q` symlink for backward compatibility with Amazon Q CLI
    symlink "bin/kiro-cli", "bin/q", source_base: :homebrew_prefix, target_base: :homebrew_prefix,
            overwrite: true
  end

  uninstall_postflight_steps do
    remove "bin/q", base: :homebrew_prefix
  end

  zap trash: [
    "~/.config/kiro",
    "~/.kiro",
    "~/.local/share/kiro",
  ]
end
