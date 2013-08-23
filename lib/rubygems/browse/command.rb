require 'rubygems/command'

module Gem::Browse
  class Command < Gem::Command

    def add_editor_option
      add_option('-e', '--editor EDITOR', 'Specify editor to invoke') do |editor, options|
        options[:editor] = editor
      end
    end

    def editor
      options[:editor] ||
        ENV['GEM_EDITOR'] ||
        ENV['VISUAL'] ||
        ENV['EDITOR'] ||
        'vi'
    end

    def edit(*args)
      unless system(*editor.split(/\s+/) + args)
        alert_error "Problem with editor #{editor}"
        terminate_interaction 1
      end
    end
    
    def add_browser_option
      add_option('-b', '--browser BROWSER', 'Specify browser to invoke') do |browser, options|
        options[:browser] = browser
      end
    end
    
    def browser
      options[:browser] ||
        ENV['GEM_BROWSER'] ||
        ENV['TOOL'] ||
        ENV['BROWSER'] ||
        'firefox'
    end
    
    def browse(homepage)
      browser_with_options = browser.split(/\s+/) || []
      browser_with_options.unshift( '--browser=' + browser_with_options.shift) if !browser_with_options.empty?
      unless system("git web--browse #{browser_with_options.join(' ')} #{homepage} > /dev/null")
        alert_error "Error starting web browser (using git web--browse) or some thing wrong with #{browser}."
        terminate_interaction 1
      end
    end

    def find_by_name(*args)
      if Gem::Specification.respond_to?(:find_by_name)
        Gem::Specification.find_by_name(*args)
      else
        Gem.source_index.find_name(*args).last or raise Gem::LoadError
      end
    end

    def get_json(name)
      require 'open-uri'
      begin
        open("http://rubygems.org/api/v1/gems/#{name}.json").read
      rescue OpenURI::HTTPError
        alert_error "Cannot retrieve gem information for #{name} from rubygems.org."
        terminate_interaction 1
      end
    end

  end
end
