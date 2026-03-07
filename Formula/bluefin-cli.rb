class BluefinCli < Formula
  desc "Bluefin's CLI tool"
  homepage "https://github.com/hanthor/bluefin-cli"
  url "https://github.com/hanthor/bluefin-cli/archive/refs/tags/v0.0.5.tar.gz"
  sha256 "0a8efad10ff9c6efb83f529118af9f670366db1ddd4493484a1c3f0b492e2f1e"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
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
