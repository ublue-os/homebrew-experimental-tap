cask "webex-linux" do
  version "46.8.0.35631"
  sha256 :no_check

  url "https://binaries.webex.com/WebexDesktop-CentOS-Official-Package/Webex.rpm"
  name "Webex"
  desc "Calling, messaging, and meeting app by Cisco"
  homepage "https://www.webex.com/downloads.html"

  livecheck do
    url "https://client-upgrade-a.wbx2.com/client-upgrade/api/v1/webexteamsdesktop/upgrade/@me?channel=gold&model=centos"
    strategy :json do |json|
      json.dig("manifest", "version")
    end
  end

  auto_updates true
  depends_on linux: :any
  depends_on formula: "cpio"
  depends_on formula: "rpm2cpio"
  depends_on formula: "libxcrypt-compat"

  binary "opt/Webex/bin/CiscoCollabHost", target: "webex"
  artifact "opt/Webex/bin/sparklogosmall.png",
           target: "#{Dir.home}/.local/share/pixmaps/webex.png"
  artifact "opt/Webex/bin/webex.desktop",
           target: "#{Dir.home}/.local/share/applications/webex.desktop"

  preflight do
    rpm_path = staged_path/"Webex.rpm"
    rpm2cpio = Formula["rpm2cpio"].bin/"rpm2cpio"
    cpio = Formula["cpio"].bin/"cpio"
    system "sh", "-c", "'#{rpm2cpio}' '#{rpm_path}' | '#{cpio}' -idm --quiet", chdir: staged_path
    FileUtils.rm rpm_path

    FileUtils.touch staged_path/"opt/Webex/bin/rpm.dat"

    FileUtils.rm staged_path/"opt/Webex/lib/libstdc++.so.6", force: true

    desktop_file = staged_path/"opt/Webex/bin/webex.desktop"
    content = File.read(desktop_file)
    content.gsub!(/^Exec=.*/, "Exec=#{HOMEBREW_PREFIX}/bin/webex %U")
    content.gsub!(/^Icon=.*/, "Icon=#{Dir.home}/.local/share/pixmaps/webex.png")
    File.write(desktop_file, content)
  end

  postflight do
    system "xdg-mime", "default", "webex.desktop",
           "x-scheme-handler/webexteams",
           "x-scheme-handler/ciscospark",
           "x-scheme-handler/webex"

    webex_wrapper = HOMEBREW_PREFIX/"bin/webex"
    if webex_wrapper.exist?
      libxcrypt_lib = Formula["libxcrypt-compat"].lib
      content = File.read(webex_wrapper)
      unless content.include?(libxcrypt_lib.to_s)
        content.gsub!(/^exec /, "export LD_LIBRARY_PATH=\"#{libxcrypt_lib}:$LD_LIBRARY_PATH\"\nexec ")
        File.write(webex_wrapper, content)
      end
    end
  end

  zap trash: [
    "~/.cache/Cisco",
    "~/.config/Cisco",
    "~/.local/share/Cisco",
    "~/.local/share/Webex",
    "~/.local/share/WebexLauncher",
  ]

  caveats <<~EOS
    Webex does not bundle every library it links against. Install them before
    launching if missing:
      Fedora/RHEL-family: sudo rpm-ostree install libXScrnSaver
      Debian/Ubuntu-family: sudo apt install libxss1
  EOS
end
