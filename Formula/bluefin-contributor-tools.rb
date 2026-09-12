class BluefinContributorTools < Formula
  desc "Bluefin Review & Contribute CLI tools powered by Apptainer"
  homepage "https://github.com/projectbluefin/review"
  url "https://github.com/projectbluefin/review/archive/refs/heads/main.tar.gz"
  version "0.1.0"
  license "Apache-2.0"
  head "https://github.com/projectbluefin/review.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "apptainer"

  def install
    # Install the CLI wrappers
    bin.install "bin/bluefin"
    bin.install "bin/bluefin-contribute"

    # Install companion scripts/assets if present
    pkgshare.install "Justfile" if File.exist?("Justfile")
    pkgshare.install "justfile" if File.exist?("justfile")
  end

  def caveats
    <<~EOS
      Bluefin Contributor Tools runs containerized under Apptainer.

      To start the Hive contributor worker:
        bluefin contribute
        # or: bluefin-contribute

      To review pull requests:
        bluefin review
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/bluefin 2>&1", 2)
  end
end
