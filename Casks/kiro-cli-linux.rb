cask "kiro-cli-linux" do
  arch arm:   "aarch64",
       intel: "x86_64"

  version "2.37.1"
  sha256 arm64_linux:  "e589bd8d8b845bb193b9f36f2ee263fe8aef7dbb19aff03ce44c5076ce6ab0c1",
         x86_64_linux: "b4049000d5a7b684947306eb9f9a480cab3a3ab2ff42584c293d05bde4d314a1"

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
