#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "optparse"
require "uri"

# Checks GitLab releases for updates to Homebrew formulas
class GitLabReleaseChecker
  attr_reader :project_path, :formula_name, :gitlab_token, :manual_version

  def initialize(project_path: "asus-linux/asusctl", formula_name: "asusctl", manual_version: nil)
    @project_path = project_path
    @formula_name = formula_name
    @gitlab_token = ENV.fetch("GITLAB_TOKEN", nil)
    @manual_version = manual_version
  end

  def fetch_latest_release
    encoded_path = URI.encode_www_form_component(@project_path)
    url = "https://gitlab.com/api/v4/projects/#{encoded_path}/releases/permalink/latest"

    response = fetch_with_redirect(url)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      normalize_version(data["tag_name"] || "")
    else
      warn "Error fetching GitLab release: #{response.code} #{response.message}"
      nil
    end
  rescue => e
    warn "Error fetching GitLab release: #{e.message}"
    nil
  end

  def fetch_with_redirect(url, limit = 10)
    raise "Too many redirects" if limit.zero?

    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri)
    request["PRIVATE-TOKEN"] = @gitlab_token if @gitlab_token

    response = http.request(request)

    if response.is_a?(Net::HTTPRedirection)
      fetch_with_redirect(URI.join(url, response["location"]).to_s, limit - 1)
    else
      response
    end
  end

  def normalize_version(version)
    version.sub(/^v/, "")
  end

  def get_formula_version(formula_path = nil)
    formula_path ||= "Formula/#{@formula_name}.rb"

    unless File.exist?(formula_path)
      warn "Formula not found: #{formula_path}"
      return
    end

    content = File.read(formula_path, encoding: "utf-8")

    patterns = [
      /tag:\s+"v?([^"]+)"/,
      %r{url.*/archive/v?([^/]+)/asusctl-},
      /version\s+"([^"]+)"/,
    ]

    patterns.each do |pattern|
      match = content.match(pattern)
      return normalize_version(match[1]) if match
    end

    nil
  end

  def compare_versions(gitlab_version, formula_version)
    needs_update = gitlab_version != formula_version

    {
      needs_update:    needs_update,
      latest_version:  gitlab_version,
      current_version: formula_version,
      new_version:     needs_update ? gitlab_version : "",
    }
  end

  def update_github_output(data)
    return unless ENV["GITHUB_OUTPUT"]

    File.open(ENV.fetch("GITHUB_OUTPUT", nil), "a") do |file|
      data.each do |key, value|
        booleans = [true, false]
        value = value.to_s.downcase if booleans.include?(value)
        file.puts "#{key}=#{value}"
        file.puts "#{@formula_name}_#{key}=#{value}"
      end
    end
  end

  def write_github_summary(data)
    return unless ENV["GITHUB_STEP_SUMMARY"]

    status = data[:needs_update] ? "Update needed" : "Up-to-date"
    action = data[:needs_update] ? "Formula will be updated automatically" : "No action required"

    summary = <<~MARKDOWN
      # GitLab Release Check Results

      ## Formula: #{@formula_name}

      | Property | Value |
      |----------|-------|
      | Current Formula Version | #{data[:current_version]} |
      | Latest GitLab Release | #{data[:latest_version]} |
      | Status | #{status} |
      | Action | #{action} |

      ### Details
      - **Project**: #{@project_path}
      - **Checked at**: GitLab API latest release endpoint
    MARKDOWN

    File.open(ENV.fetch("GITHUB_STEP_SUMMARY", nil), "a") do |file|
      file.write(summary)
    end
  end

  def run
    gitlab_version = if @manual_version
      puts "Using manually specified version: #{@manual_version}"
      normalize_version(@manual_version)
    else
      puts "Checking GitLab for latest release..."
      version = fetch_latest_release

      unless version
        warn "Failed to fetch GitLab release"
        return 1
      end

      version
    end

    puts "Target version: #{gitlab_version}"

    formula_version = get_formula_version
    if formula_version.nil?
      puts "Could not determine formula version, assuming update needed"
      formula_version = "unknown"
    else
      puts "Current formula version: #{formula_version}"
    end

    result = compare_versions(gitlab_version, formula_version)
    update_github_output(result)
    write_github_summary(result)

    if result[:needs_update]
      puts "New version available: #{gitlab_version} → Update needed!"
      puts "New #{@formula_name} version #{gitlab_version} is available"
    else
      puts "Formula is up-to-date at version #{gitlab_version}"
    end

    0
  end

  def self.parse_options
    options = {
      formula: "asusctl",
      project: "asus-linux/asusctl",
      version: nil,
    }

    OptionParser.new do |opts|
      opts.banner = "Usage: check_gitlab_release.rb [options]"

      opts.on("--formula FORMULA", "Formula name (default: asusctl)") do |v|
        options[:formula] = v
      end

      opts.on("--project PROJECT", "GitLab project path (default: asus-linux/asusctl)") do |v|
        options[:project] = v
      end

      opts.on("--version VERSION", "Manually specify version to check against (skips GitLab API call)") do |v|
        options[:version] = v
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end.parse!

    options
  end
end

# Script execution
if __FILE__ == $PROGRAM_NAME
  options = GitLabReleaseChecker.parse_options

  checker = GitLabReleaseChecker.new(
    project_path:   options[:project],
    formula_name:   options[:formula],
    manual_version: options[:version],
  )

  exit(checker.run)
end
