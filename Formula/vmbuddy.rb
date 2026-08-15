class Vmbuddy < Formula
  desc "QEMU wrapper with sensible defaults"
  homepage "https://github.com/tulilirockz/vmbuddy"
  url "https://github.com/tulilirockz/vmbuddy/archive/refs/tags/0.1.3.tar.gz"
  sha256 "3906b7e8aeae3af48e41f1230e8cc2bc5e9c67a6f814070a7d84257834729873"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_latest
    regex(/^v?(\d+(?:\.\d+)+(?:-rc\.\d+)?)$/i)
  end

  def install
    bin.install "vmbuddy.sh" => "vmbuddy"
    bin.install_symlink "vmbuddy" => "vm"
  end

  test do
    assert_match "Usage", shell_output("#{bin}/vmbuddy --help 2>&1")
  end
end
