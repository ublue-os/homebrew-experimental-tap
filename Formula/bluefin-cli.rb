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
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/bluefin-cli-0.6.4"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_linux:  "526f7075dd47bf1875bff08ddd668f2fb245ad95d5807bda9af8995570c9b73f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f52d1e2c882000727b093cb31aafd5d7a3fe92e3d11b89f27606796db9b7197c"
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
