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
           target: "#{Dir.home}/.local/share/icons/webex.png"
  artifact "opt/Webex/bin/webex.desktop",
           target: "#{Dir.home}/.local/share/applications/webex.desktop"

  preflight_steps do
    run "{{HOMEBREW_PREFIX}}/bin/rpm2cpio", args:        ["{{staged_path}}/Webex.rpm"],
                                            stdout_path: "webex.cpio"
    run "{{HOMEBREW_PREFIX}}/bin/cpio", args: ["-idm", "--quiet"], stdin_path: "webex.cpio",
        chdir: "{{staged_path}}"
    remove "Webex.rpm"
    remove "webex.cpio"

    touch "opt/Webex/bin/rpm.dat"
    remove "opt/Webex/lib/libstdc++.so.6"

    inreplace "opt/Webex/bin/webex.desktop", /^Exec=.*/,
              "Exec={{HOMEBREW_PREFIX}}/bin/webex %U", audit_result: false
    inreplace "opt/Webex/bin/webex.desktop", /^Icon=.*/, "Icon=webex", audit_result: false
  end

  postflight_steps do
    # Give xdg-mime a stable HOME whose .config directory is a narrow handle
    # onto the real user's configuration directory.
    mkdir_p ".config", base: :home
    mkdir_p "webex-home"
    symlink ".config", "webex-home/.config", source_base: :home
    run "xdg-mime",
        args: ["default", "webex.desktop", "x-scheme-handler/webexteams",
               "x-scheme-handler/ciscospark", "x-scheme-handler/webex"],
        env: {
          "HOME"            => "{{staged_path}}/webex-home",
          "XDG_CONFIG_HOME" => "{{staged_path}}/webex-home/.config",
        },
        must_succeed: false, writable_paths: [".config"], writable_base: :home

    # The binary artifact created `{{HOMEBREW_PREFIX}}/bin/webex` as a symlink to
    # the staged CiscoCollabHost, so modifying the staged file is equivalent. Keep
    # the idempotent marker guard exactly as the original (insert only when absent).
    run "sh",
        args: ["-c", <<~SH]
          wrapper="{{staged_path}}/opt/Webex/bin/CiscoCollabHost"
          marker="{{HOMEBREW_PREFIX}}/opt/libxcrypt-compat/lib"
          if [ -f "$wrapper" ] && ! grep -qF "$marker" "$wrapper"; then
            sed -i 's#^exec #export LD_LIBRARY_PATH="'"$marker"':$LD_LIBRARY_PATH"\\nexec #' "$wrapper"
          fi
        SH
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
