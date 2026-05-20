class AntigravitySdk < Formula
  desc "Python SDK for building with Google Antigravity"
  homepage "https://github.com/google-antigravity/antigravity-sdk-python"
  url "https://github.com/google-antigravity/antigravity-sdk-python.git", branch: "main"
  version "0.1.0"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    python = Formula["python@3.12"].opt_bin/"python3.12"
    venv = libexec/"venv"
    system python, "-m", "venv", venv
    pip = venv/"bin/pip"
    system pip, "install", "-e", "."
    bin.install_symlink venv/"bin/antigravity-sdk"
  end

  def caveats
    <<~EOS
      The Antigravity SDK has been installed. To use it in your Python projects:

        pip install antigravity-sdk

      Or use the installed command-line tool:
        antigravity-sdk --help
    EOS
  end

  test do
    system bin/"antigravity-sdk", "--help"
  end
end
