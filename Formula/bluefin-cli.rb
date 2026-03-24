class BluefinCli < Formula
  desc "Bluefin's CLI tool"
  homepage "https://github.com/hanthor/bluefin-cli"
  url "https://github.com/hanthor/bluefin-cli/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "7223ef2c8df97864f86553fd9b040661c7de564e13ca2562276c826ba42284af"
  license "Apache-2.0"
  head "https://github.com/hanthor/bluefin-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/bluefin-cli-0.6.0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a2879ea92f61ecaeb490ae9f168ede6c626750fb3919f8cf8bca2cd260279624"
    sha256 cellar: :any_skip_relocation, arm64_linux:  "a7fecff72ff78d2e5ee7286eab0c47b0c70dd8f5db1ab1ca2ff712582f59b109"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bluefin-cli --version")
  end
end
