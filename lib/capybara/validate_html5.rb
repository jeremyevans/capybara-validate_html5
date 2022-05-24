require 'capybara'

module Capybara
  unless Capybara.respond_to?(:use_html5_parsing) && defined?(Nokogiri::HTML5)
    raise LoadError, "capybara-validate_html5 cannot be used as Capybara or Nokogiri doesn't support HTML5 parsing (require capybara/optionally_validate_html5 to make validation optional)"
  end

  self.use_html5_parsing = true

  require 'capybara/rack_test/browser'
  require 'capybara/dsl'
  require 'minitest'

  module RackTest::ValidateDom
    # Skip HTML validation inside the block.
    def skip_html_validation
      skip = @skip_html_validation
      @skip_html_validation = true
      yield
    ensure
      @skip_html_validation = skip
    end

    # If loading the DOM for the first time and not skipping
    # HTML validation, validate the HTML and expect no errors.
    def dom
      unless @dom || @skip_html_validation
        errors = Nokogiri::HTML5(html, max_errors: 10).errors
        unless errors.empty?
          first_error_line = errors.first.line
          begin_line = first_error_line - 3
          end_line = first_error_line + 3
          begin_line = 0 if begin_line < 0
          called_from = caller_locations.detect do |loc|
            loc.path !~ %r{lib/(capybara|nokogiri|minitest)}
          end
          errors.must_be_empty(<<END_MSG)
invalid HTML on page returned for #{last_request.path}, called from #{called_from.path}:#{called_from.lineno}

#{html.split("\n")[begin_line..end_line].join("\n")}

END_MSG
        end
      end
      super
    end

    # Skip HTML validation during base_href calculations.
    def base_href
      skip_html_validation{super}
    end
  end

  RackTest::Browser.prepend(RackTest::ValidateDom)

  module DSL
    # Skip HTML validation inside the block.
    def skip_html_validation(&block)
      page.driver.browser.skip_html_validation(&block)
    end
  end
end
