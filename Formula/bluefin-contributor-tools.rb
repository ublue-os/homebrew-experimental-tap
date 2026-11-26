class BluefinContributorTools < Formula
  desc "Contributor and review tooling for Project Bluefin"
  homepage "https://github.com/projectbluefin/review"
  url "https://github.com/projectbluefin/review/archive/refs/tags/v26.08.05.tar.gz"
  version "26.08.05"
  sha256 "3e7f5f4c10a116497011c49536b356c7ff1a51e84d234e2a7551b6fb41ab2f4d"
  license "Apache-2.0"

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
