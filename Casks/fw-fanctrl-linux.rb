cask "fw-fanctrl-linux" do
  version "1.0.4,1"
  sha256 "1eaf2e48cc39a3e98f978c0ce8efb472d26ffb0277d5f29c8e614705e01beee7"

  release_tag = "fw-fanctrl-#{version.csv.first}-#{version.csv.second}"
  release_root = "fw-fanctrl-#{version.csv.first}-x86_64"

  url "https://github.com/ublue-os/homebrew-experimental-tap/releases/download/#{release_tag}/#{release_root}.tar.gz"
  name "fw-fanctrl"
  desc "Framework laptop fan controller daemon and CLI"
  homepage "https://github.com/TamtamHero/fw-fanctrl"

  livecheck do
    url "https://api.github.com/repos/ublue-os/homebrew-experimental-tap/releases"
    strategy :json do |json|
      json.filter_map do |rel|
        match = rel["tag_name"].to_s.match(/^fw-fanctrl-(\d+(?:\.\d+)+)-(\d+)$/)
        next if match.nil?

        "#{match[1]},#{match[2]}"
      end.max
    end
  end

  binary "#{release_root}/usr/bin/fw-fanctrl"
  binary "#{release_root}/usr/bin/ectool"

  postflight do
    release_dir = "#{staged_path}/#{release_root}"
    root_prefix = "/opt/ublue-fw-fanctrl"
    root_bin_dir = "#{root_prefix}/bin"
    systemd_dir = "/etc/systemd/system"
    sleep_dir = "/etc/systemd/system-sleep"
    config_dir = "/etc/fw-fanctrl"

    service_src = "#{release_dir}/usr/lib/systemd/system/fw-fanctrl.service"
    sleep_src = "#{release_dir}/usr/lib/systemd/system-sleep/fw-fanctrl-suspend"
    config_src = "#{release_dir}/usr/share/fw-fanctrl/config.json"
    schema_src = "#{release_dir}/usr/share/fw-fanctrl/config.schema.json"

    getenforce = %w[/usr/sbin/getenforce /usr/bin/getenforce /bin/getenforce].find do |path|
      File.executable?(path)
    end
    restorecon = %w[/usr/sbin/restorecon /usr/bin/restorecon /bin/restorecon].find do |path|
      File.executable?(path)
    end
    semanage = %w[/usr/sbin/semanage /usr/bin/semanage /bin/semanage].find do |path|
      File.executable?(path)
    end
    chcon = %w[/usr/sbin/chcon /usr/bin/chcon /bin/chcon].find do |path|
      File.executable?(path)
    end
    systemctl = %w[/usr/bin/systemctl /bin/systemctl].find do |path|
      File.executable?(path)
    end

    ohai "Installing fw-fanctrl payload under #{root_prefix}"

    system "sudo", "install", "-d",
           root_bin_dir, systemd_dir, sleep_dir, config_dir

    system "sudo", "install", "-Dm0755",
           "#{release_dir}/usr/bin/fw-fanctrl",
           "#{root_bin_dir}/fw-fanctrl"
    system "sudo", "install", "-Dm0755",
           "#{release_dir}/usr/bin/ectool",
           "#{root_bin_dir}/ectool"

    system "sudo", "install", "-Dm0644",
           service_src,
           "#{systemd_dir}/fw-fanctrl.service"
    system "sudo", "install", "-Dm0755",
           sleep_src,
           "#{sleep_dir}/fw-fanctrl-suspend"
    system "sudo", "install", "-Dm0644",
           schema_src,
           "#{config_dir}/config.schema.json"

    unless File.exist?("#{config_dir}/config.json")
      system "sudo", "install", "-Dm0644",
             config_src,
             "#{config_dir}/config.json"
    end

    selinux_mode = if getenforce
      IO.popen([getenforce], &:read).strip
    else
      "Disabled"
    end

    if selinux_mode != "Disabled"
      resolved_root_bin = begin
        File.realpath(root_bin_dir)
      rescue
        root_bin_dir
      end
      bin_pattern = "#{resolved_root_bin}(/.*)?"

      if semanage
        added = system "sudo", semanage, "fcontext", "-a", "-t", "bin_t", bin_pattern
        system "sudo", semanage, "fcontext", "-m", "-t", "bin_t", bin_pattern unless added
      elsif chcon
        system "sudo", chcon, "-R", "-t", "bin_t", resolved_root_bin
      end

      if restorecon
        [root_prefix, systemd_dir, sleep_dir, config_dir].each do |path|
          system "sudo", restorecon, "-RFv", path if File.exist?(path)
        end
      end
    end

    system "sudo", systemctl, "daemon-reload" if systemctl
  end

  uninstall_preflight do
    root_prefix = "/opt/ublue-fw-fanctrl"
    root_bin_dir = "#{root_prefix}/bin"
    systemd_dir = "/etc/systemd/system"
    sleep_dir = "/etc/systemd/system-sleep"
    config_dir = "/etc/fw-fanctrl"

    getenforce = %w[/usr/sbin/getenforce /usr/bin/getenforce /bin/getenforce].find do |path|
      File.executable?(path)
    end
    restorecon = %w[/usr/sbin/restorecon /usr/bin/restorecon /bin/restorecon].find do |path|
      File.executable?(path)
    end
    semanage = %w[/usr/sbin/semanage /usr/bin/semanage /bin/semanage].find do |path|
      File.executable?(path)
    end
    systemctl = %w[/usr/bin/systemctl /bin/systemctl].find do |path|
      File.executable?(path)
    end

    system "sudo", systemctl, "disable", "--now", "fw-fanctrl.service" if systemctl

    selinux_mode = if getenforce
      IO.popen([getenforce], &:read).strip
    else
      "Disabled"
    end

    if selinux_mode != "Disabled" && semanage
      resolved_root_bin = begin
        File.realpath(root_bin_dir)
      rescue
        root_bin_dir
      end
      system "sudo", semanage, "fcontext", "-d", "#{resolved_root_bin}(/.*)?"
    end

    system "sudo", "rm", "-f", "#{systemd_dir}/fw-fanctrl.service"
    system "sudo", "rm", "-f", "#{sleep_dir}/fw-fanctrl-suspend"
    system "sudo", "rm", "-f", "#{config_dir}/config.schema.json"
    system "sudo", "rm", "-rf", root_prefix
    system "sudo", "rmdir", config_dir if Dir.exist?(config_dir) && Dir.empty?(config_dir)

    system "sudo", systemctl, "daemon-reload" if systemctl
    system "sudo", restorecon, "-RFv", "/opt", "/var/opt" if restorecon && selinux_mode != "Disabled"
  end

  caveats <<~EOS
    fw-fanctrl is installed under:
      /opt/ublue-fw-fanctrl/bin/{fw-fanctrl,ectool}
      /etc/systemd/system/fw-fanctrl.service
      /etc/systemd/system-sleep/fw-fanctrl-suspend
      /etc/fw-fanctrl/config.json (default; not overwritten on upgrade)
      /etc/fw-fanctrl/config.schema.json

    To activate the daemon:
      sudo systemctl enable --now fw-fanctrl.service

    To change fan curves, edit /etc/fw-fanctrl/config.json, then:
      sudo fw-fanctrl reload

    Requires Python 3.12+ on the system (default on Bluefin and Bazzite).
    Framework laptops only; upstream: https://github.com/TamtamHero/fw-fanctrl
  EOS
end
