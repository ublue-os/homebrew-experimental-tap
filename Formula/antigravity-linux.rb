class AntigravityLinux < Formula
  desc "Google Antigravity - Next-generation agentic IDE"
  homepage "https://antigravity.google"
  url "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.11.3-6583016683339776/linux-x64/Antigravity.tar.gz"
  sha256 "025da512f9799a7154e2cc75bc0908201382c1acf2e8378f9da235cb84a5615b"
  version "1.11.3"
  license "proprietary"

  def install
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/Antigravity" => "antigravity"
  end

  test do
    system "#{bin}/antigravity", "--version"
  end
end
