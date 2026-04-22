cask "claude-code-linux" do
  version "2.1.117"
  sha256 "b7246963d9e32ece439c3e1e7885f53773a4820e90a4d2433ef2a413a055a5fe"

  url "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/#{version}/linux-x64/claude",
      verified: "storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/"
  name "Claude Code"
  desc "Terminal-based AI coding assistant by Anthropic"
  homepage "https://www.anthropic.com/claude-code"

  livecheck do
    url "https://registry.npmjs.org/@anthropic-ai/claude-code"
    regex(/"latest"\s*:\s*"(\d+(?:\.\d+)+)"/i)
  end

  binary "claude"

  zap trash: [
    "~/.cache/claude",
    "~/.claude",
    "~/.config/claude",
    "~/.local/share/claude",
    "~/.local/state/claude",
  ]
end
