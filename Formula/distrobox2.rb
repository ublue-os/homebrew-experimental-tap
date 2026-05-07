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
    sha256 cellar: :any_skip_relocation, arm64_linux:  "c1a5328237d6374d36a959a58f0ad97358ead9a8115f9dfef7b0db6dc3374946"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "52c23dc6d3f98c82323eab5dbef5dc19ed42e500ca87130ab2b51f0cce258b74"
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
