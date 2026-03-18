cask "buildbox" do
  version "1.3.52"
  sha256 "88fabb10a5c4b8ba4d7614cbca46427533fda82e49237a920f61fd4d32edb7ff"

  url "https://gitlab.com/BuildGrid/buildbox/buildbox-integration/-/releases/#{version}/downloads/buildbox-x86_64-linux-gnu.tgz"
  name "Buildbox"
  desc "Set of tools for remote worker build execution"
  homepage "https://gitlab.com/BuildGrid/buildbox"

  livecheck do
    url "https://gitlab.com/BuildGrid/buildbox/buildbox-integration/-/releases"
    regex(/href=.*?buildbox[._-]v?(\d+(?:\.\d+)+)\.tgz/i)
  end

  # Binaries from the tgz
  binary "buildbox-casd"
  binary "buildbox-fuse"
  binary "buildbox-run"
  binary "buildbox-run-bubblewrap"
end
