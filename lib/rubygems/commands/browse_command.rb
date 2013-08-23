require 'rubygems/browse/command'

class Gem::Commands::BrowseCommand < Gem::Browse::Command

  def initialize
    super 'browse', "Open a gem's homepage in your web browser"
    add_browser_option
  end

  def execute
    name = get_one_gem_name
    homepage =
      begin
        find_by_name(name).homepage
      rescue Gem::LoadError
        get_json(name)[/"homepage_uri":\s*"([^"]*)"/, 1]
      end
    homepage = "http://rubygems.org/gems/#{name}" if homepage.to_s.empty?
    browse homepage
  end

end
