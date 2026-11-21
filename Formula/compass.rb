class Compass < Formula
  desc "Fast, extensible command palette for the Linux desktop"
  homepage "https://github.com/tuna-os/compass"
  # Linux-only: the engine targets Linux sessions (Wayland, portals, logind);
  # there is no macOS or Windows backend (see ADR-0007 in the repo).
  url "https://github.com/tuna-os/compass/archive/refs/tags/v0.28.7.tar.gz"
  sha256 "23d7fa5626a3a78e8bd02398e1f571ac0acd1d7c30842e7ec2df9fb65fb26653"
  license "GPL-3.0-only"
  head "https://github.com/tuna-os/compass.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/compass-0.28.6"
    rebuild 3
    sha256 cellar: :any, arm64_linux:  "604e2dfdf35e4c2275629b65f3ffb7467c72535433ea21fbf6c7a5deccab3a48"
    sha256 cellar: :any, x86_64_linux: "877760508031d225088ab0ecf9439da96e8dce5bfd38e010b72f6a68f5968cd8"
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
