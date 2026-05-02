class Distrobox2 < Formula
  desc "Use any linux distribution inside your terminal. (Release Candidate for v2)"
  homepage "https://github.com/89luca89/distrobox"
  url "https://github.com/89luca89/distrobox/archive/refs/tags/2.0.0-rc.2.tar.gz"
  sha256 "515dc733acf7fe716fd9d243f40fbcb4898b307094039c8106aafb60bbdd705e"
  license "GPL-3.0-or-later"
  head "https://github.com/89luca89/distrobox.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+(?:-rc\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/distrobox2-2.0.0-rc.2"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_linux:  "54d8b328d9669a6bc40eab8c9436d26be13cbe5284760929f082a21e75e78548"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c4763502758da481b4870735d255a500e6d612627943fd7ef80f7d0e672f66fe"
  end

  depends_on "go" => :build

  def install
    # Build the distrobox binary
    system "go", "build",
           "-ldflags", "-s -w -X main.Version=#{version}",
           "-o", "distrobox2",
           "./cmd/distrobox"

    bin.install "distrobox2"
  end

  test do
    output = shell_output("#{bin}/distrobox2 --version")
    assert_includes output, "distrobox"
  end
end
