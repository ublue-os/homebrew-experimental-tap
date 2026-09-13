class BluefinContributorTools < Formula
  desc "Contributor and review tooling for Project Bluefin"
  homepage "https://github.com/projectbluefin/review"
  url "https://github.com/projectbluefin/review.git", branch: "omp-port"
  version "0.2.1"
  license "Apache-2.0"

  livecheck do
    skip "Tracks the development branch; no tagged releases yet"
  end

  bottle do
    root_url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/bluefin-contributor-tools-0.2.1"
    rebuild 2
    sha256 cellar: :any_skip_relocation, x86_64_linux: "01ed39ffdfb2d90fb0af4817609e3efde5febcf866f21e5a637cd8539fa12689"
  end

  on_macos do
    depends_on "node"
  end

  on_linux do
    depends_on "apptainer"
  end

  def install
    if OS.linux?
      bin.install "bin/bluefin"
      bin.install "bin/bluefin-contribute"
      (pkgshare/"apparmor").install "image/apparmor/apptainer" if File.exist?("image/apparmor/apptainer")
    elsif OS.mac?
      bin.install "bin/bluefin"
      bin.install "bin/bluefin-contribute"
    end
  end

  def caveats
    if OS.linux?
      <<~EOS
        bluefin and bluefin-contribute require Apptainer to run containerized tools:
          https://apptainer.org/docs/admin/main/installation.html

        On modern Linux (e.g. Ubuntu 24.04+), an AppArmor profile for Apptainer's
        unprivileged user namespaces is provided at:
          #{opt_pkgshare}/apparmor/apptainer
        Load it with:
          sudo apparmor_parser -r #{opt_pkgshare}/apparmor/apptainer

        You will also need the corresponding SIF images or set:
          export BLUEFIN_REVIEW_SIF=/path/to/bluefin-review.sif
          export BLUEFIN_CONTRIBUTE_SIF=/path/to/bluefin-contribute.sif
      EOS
    else
      <<~EOS
        On macOS and Windows (via PowerShell / WSL), Bluefin Review uses the native
        bundle or container runtime:
          https://github.com/projectbluefin/review/releases
      EOS
    end
  end

  test do
    output = shell_output("#{bin}/bluefin 2>&1", 2)
    assert_match "Usage: bluefin {contribute|review}", output

    system "bash", "-n", bin/"bluefin"
    system "bash", "-n", bin/"bluefin-contribute"
  end
end
