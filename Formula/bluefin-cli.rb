class BluefinCli < Formula
  desc "Bluefin's CLI tool"
  homepage "https://github.com/hanthor/bluefin-cli"
  url "https://github.com/hanthor/bluefin-cli/archive/refs/tags/v0.0.3.tar.gz"
  sha256 "df61ae6dd59220720d63e9624b5f4c7a59c64fb727008cef5e961423cbe3b082"
  license "Apache-2.0"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "version", shell_output("#{bin}/bluefin-cli --version")
  end
end
