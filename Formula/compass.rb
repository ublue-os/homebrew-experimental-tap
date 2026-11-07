class Compass < Formula
  desc "Fast, extensible command palette for the Linux desktop"
  homepage "https://github.com/tuna-os/compass"
  # Linux-only: the engine targets Linux sessions (Wayland, portals, logind);
  # there is no macOS or Windows backend (see ADR-0007 in the repo).
  url "https://github.com/tuna-os/compass/archive/refs/tags/v0.28.4.tar.gz"
  sha256 "dba149891697c3e0d4fd4ffa398bd540dbcce49e803ba1990da4489e880da700"
  license "GPL-3.0-only"
  head "https://github.com/tuna-os/compass.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/compass-0.28.4"
    rebuild 2
    sha256 cellar: :any, arm64_linux:  "2e25be5bb1355c2a656ba58be1fa8f05d7cbcfc5698727ac08c72b7dee25d62f"
    sha256 cellar: :any, x86_64_linux: "05c80452aba1a1a25412ab7fb327ead52a38e7124af3b9d5e77c4ac30040b887"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libxkbcommon"
  depends_on :linux
  depends_on "node"
  depends_on "openssl@3"

  def install
    # The extension runtime bundle the engine refuses to run without.
    system "./scripts/build-extension-runtime.sh"
    # One install per crate: `-p` cannot combine with the `--path` inside
    # `std_cargo_args` (cargo rejects it), and `brew audit` refuses
    # `cargo build` outright. A shared target dir keeps the three installs
    # from rebuilding dependencies three times. The layout below mirrors
    # scripts/packaging/install-rust-engine.sh, which stays the canonical
    # list of what an install contains.
    ENV["CARGO_TARGET_DIR"] = buildpath/"cargo-target"
    system "cargo", "install", *std_cargo_args(path: "crates/compass")
    system "cargo", "install", "--bin", "compass-sandbox-exec",
           *std_cargo_args(path: "crates/compass-sandbox")
    system "cargo", "install", *std_cargo_args(path: "crates/compass-input-server")
    # cargo install puts every binary on PATH, but the engine finds its
    # helpers in ../libexec/compass from bin/ — so they move there.
    (libexec/"compass").mkpath
    %w[compass-file-indexer compass-sandbox-exec compass-input-server].each do |helper|
      mv bin/helper, libexec/"compass"
    end
    (share/"applications").install "packaging/flatpak/org.tunaos.compass.desktop"
    (share/"metainfo").install "packaging/flatpak/org.tunaos.compass.metainfo.xml"
    (share/"icons/hicolor/scalable/apps").install "extra/compass.svg" => "org.tunaos.compass.svg"
    (share/"compass/builtin-icons").install Dir["extra/builtin-icons/*.svg"]
    (share/"compass").install "packaging/schema/compass.schema.json"
    (share/"compass").install "src/typescript/extension-manager/dist/runtime.js" => "extension-runtime.js"
    Dir["extensions/rhai-examples/*/"].each do |dir|
      (share/"compass/scripts/#{File.basename(dir)}").install Dir["#{dir}/{script.toml,*.rhai}"]
    end
    (lib/"systemd/user").install "packaging/systemd/compass.service"
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
