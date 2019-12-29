#!/bin/env ruby

require 'capybara'
require 'capybara/dsl'
require 'json'
require 'pathname'
require 'selenium/webdriver'

class CurseDownloader
  include Capybara::DSL

  CURSE_URL = 'https://minecraft.curseforge.com'

  attr_reader :manifest_path

  def initialize(manifest_path)
    @manifest_path = manifest_path
    download_path = Pathname.new(Dir.pwd).join 'mods'

    Capybara.register_driver :chrome do |app|
      opts = Selenium::WebDriver::Chrome::Options.new
      opts.add_argument('--headless') unless ENV['UI']
      opts.add_argument('--no-sandbox')
      opts.add_argument('--disable-gpu')
      opts.add_argument('--disable-dev-shm-usage')
      opts.add_argument('--window-size=1400,1400')

      opts.add_preference(:download,
                          directory_upgrade: true,
                          prompt_for_download: false,
                          default_directory: download_path)

      opts.add_preference(:browser, set_download_behavior: { behavior: 'allow' })
      chrome_options = opts
      driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options)
      bridge = driver.browser.send(:bridge)

      path = '/session/:session_id/chromium/send_command'
      path[':session_id'] = bridge.session_id

      bridge.http.call(:post, path, cmd: 'Page.setDownloadBehavior', params: {
          behavior: 'allow',
          downloadPath: download_path
      })
      driver
    end

    Capybara.run_server = false
    Capybara.current_driver = :chrome
  end

  def start
    manifest = JSON.load(@manifest_path)
    files = manifest['files']
    files.each_with_index do |file, index|
      puts "downloading #{index}/#{files.length} | #{(index + 1.0) / files.length * 100}%"
      project_id = file['projectID']
      file_id = file['fileID']
      download project_url(project_id), file_id
    end
  end

  private

  def project_url(project_id)
    "#{CURSE_URL}/projects/#{project_id}"
  end

  def download_url(path, file_id)
    Pathname.new(path).join('download', file_id.to_s)
  end

  def download(url, file_id)
    visit url
    download_url = download_url(current_url, file_id)
    puts "downloading #{download_url}"
    visit download_url
    find("[data-tracking-opt-in-accept]").click rescue nil # cookie banner
    click_on "here" # start download
  end
end

CurseDownloader.new(IO.read(ARGV[0])).start


