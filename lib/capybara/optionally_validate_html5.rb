require 'capybara'

if Capybara.respond_to?(:use_html5_parsing) && defined?(Nokogiri::HTML5)
  require_relative 'validate_html5'
else
  module Capybara::DSL
    # If HTML5 validation isn't supported, make this a no-op.
    def skip_html_validation
      yield
    end
  end
end
