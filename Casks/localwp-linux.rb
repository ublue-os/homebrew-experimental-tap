cask "localwp-linux" do
  version "10.1.1,6939"
  sha256 "e5c9c957fc128b4688a485497f7fc33cefa33ab86af81c0ee764c0d708998498"

  url "https://cdn.localwp.com/releases-stable/#{version.csv.first}+#{version.csv.second}/local-#{version.csv.first}-linux.deb"
  name "LocalWP"
  desc "Local WordPress development environment"
  homepage "https://localwp.com/"

  # There is no version index: the GCS bucket denies listing, localwp.com/releases
  # is JS-rendered and stale, and no electron-updater manifest is published. The
  # /stable/latest/deb endpoint 302s to the current build, so read the version out
  # of the redirect. Same approach homebrew-cask uses for the `local` cask.
  livecheck do
    url "https://cdn.localwp.com/stable/latest/deb"
    regex(%r{/(\d+(?:\.\d+)+)\+(\d+)/}i)
    strategy :header_match do |headers, regex|
      match = headers["location"]&.match(regex)
      next if match.blank?

      "#{match[1]},#{match[2]}"
    end
  end

  auto_updates true
  depends_on linux: :any
  # Upstream publishes an amd64 deb only; the control file declares Architecture: amd64.
  depends_on arch: :x86_64
  depends_on formula: "dpkg"

  binary "opt/Local/local", target: "localwp"

  preflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.mkdir_p "#{xdg_data}/applications"
    FileUtils.mkdir_p "#{xdg_data}/icons/hicolor/512x512/apps"

    # Extract the deb package
    deb_file = "#{staged_path}/local-#{version.csv.first}-linux.deb"
    system "dpkg", "-x", deb_file, staged_path
    FileUtils.rm(deb_file, force: true)
  end

  postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")

    icon_source = "#{staged_path}/usr/share/icons/hicolor/512x512/apps/local.png"
    icon_target = "#{xdg_data}/icons/hicolor/512x512/apps/localwp.png"
    FileUtils.cp(icon_source, icon_target) if File.exist?(icon_source)

    File.write("#{xdg_data}/applications/localwp.desktop", <<~EOS)
      [Desktop Entry]
      Name=LocalWP
      Comment=Local WordPress development environment
      GenericName=WordPress Development Tool
      Exec=#{HOMEBREW_PREFIX}/bin/localwp %U
      Icon=#{icon_target}
      Type=Application
      StartupNotify=true
      StartupWMClass=Local
      Categories=Development;
      MimeType=x-scheme-handler/flywheel-local;
      Keywords=wordpress;local;development;web;
    EOS
  end

  uninstall_postflight do
    xdg_data = ENV.fetch("XDG_DATA_HOME", "#{Dir.home}/.local/share")
    FileUtils.rm("#{xdg_data}/applications/localwp.desktop", force: true)
    FileUtils.rm("#{xdg_data}/icons/hicolor/512x512/apps/localwp.png", force: true)
  end

  zap trash: [
    "~/.config/Local",
    "~/.local/share/Local",
    "~/Local Sites",
  ]
end
