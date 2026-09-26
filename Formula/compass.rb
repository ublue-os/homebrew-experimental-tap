class Compass < Formula
  desc "Fast, extensible command palette for the Linux desktop"
  homepage "https://github.com/tuna-os/compass"
  # Linux-only: the engine targets Linux sessions (Wayland, portals, logind);
  # there is no macOS or Windows backend (see ADR-0007 in the repo).
  url "https://github.com/tuna-os/compass/archive/refs/tags/v0.28.2.tar.gz"
  sha256 "0d6e30f4607c139cdcca509546fcdb30f07a87b6849cab8d664de0a60edb0547"
  license "GPL-3.0-only"
  head "https://github.com/tuna-os/compass.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :linux

  depends_on "rust" => :build
  depends_on "pkg-config" => :build
  depends_on "node" => :build
  depends_on "openssl@3"
  depends_on "libxkbcommon"

  def install
    # The extension runtime bundle the engine refuses to run without.
    system "./scripts/build-extension-runtime.sh"
    # The same binary set every other package builds (see
    # scripts/packaging/install-rust-engine.sh).
    system "cargo", "build", "--release", "--locked",
           "-p", "compass",
           "-p", "compass-sandbox",
           "-p", "compass-input-server",
           "--bins"
    ENV["PREFIX"] = prefix
    ENV["REQUIRE_RUNTIME"] = "1"
    system "./scripts/packaging/install-rust-engine.sh"
  end

  def caveats
    <<~EOS
      Snippet keyword expansion needs a capability on its keyboard helper:
        sudo setcap cap_dac_override+ep #{opt_libexec}/compass/compass-input-server
      See "The input server" in https://github.com/tuna-os/compass/blob/main/packaging/README.md.
    EOS
  end

  test do
    # Without the workspace version tracking the release tag, --version
    # reports a stale number and this fails: that is the version-sync test
    # (crates/compass/tests/version_sync.rs) speaking through the bottle.
    assert_match version.to_s, shell_output("#{bin}/compass --version")
  end
end
