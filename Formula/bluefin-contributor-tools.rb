class BluefinContributorTools < Formula
  desc "Contributor and review tooling for Project Bluefin"
  homepage "https://github.com/projectbluefin/review"
  url "https://github.com/projectbluefin/review.git", branch: "omp-port"
  version "0.1.0"
  license "Apache-2.0"

  livecheck do
    skip "Tracks the development branch; no tagged releases yet"
  end

  depends_on :linux
  depends_on "apptainer"

  def install
    bin.install "bin/bluefin"
    bin.install "bin/bluefin-contribute"
  end

  def caveats
    <<~EOS
      bluefin and bluefin-contribute require Apptainer to run containerized tools:
        https://apptainer.org/docs/admin/main/installation.html

      You will also need the corresponding SIF images or set:
        export BLUEFIN_REVIEW_SIF=/path/to/bluefin-review.sif
        export BLUEFIN_CONTRIBUTE_SIF=/path/to/bluefin-contribute.sif
    EOS
  end

  test do
    # bin/bluefin exits with status 2 and prints usage when run without subcommands
    output = shell_output("#{bin}/bluefin 2>&1", 2)
    assert_match "Usage: bluefin {contribute|review}", output

    # Validate that installed scripts are valid bash
    system "bash", "-n", bin/"bluefin"
    system "bash", "-n", bin/"bluefin-contribute"
  end
end
