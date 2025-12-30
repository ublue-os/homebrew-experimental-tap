class BluefinCli < Formula
  desc "Bluefin's CLI tool"
  homepage "https://github.com/hanthor/bluefin-cli"
  url "https://github.com/hanthor/bluefin-cli.git",
      tag:      "v0.0.3",
      revision: "a02c6ff89cf17e23e483b56959412ec8fbc85e6f"
  license "Apache-2.0"
  head "https://github.com/hanthor/bluefin-cli. git", branch: "master"

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "version", shell_output("#{bin}/bluefin-cli --version")
  end
end
