if ENV.delete('COVERAGE')
  require 'simplecov'

  SimpleCov.start do
    enable_coverage :branch
    add_filter "/spec/"
    add_group('Missing'){|src| src.covered_percent < 100}
    add_group('Covered'){|src| src.covered_percent == 100}
  end
end

ENV['MT_NO_PLUGINS'] = '1' # Work around stupid autoloading of plugins
gem 'minitest'
require 'minitest/global_expectations/autorun'
require 'capybara'
require 'capybara/dsl'
require_relative '../lib/capybara/optionally_validate_html5'
begin
  require_relative '../lib/capybara/validate_html5'
rescue LoadError
  optional = true
end

s = (<<END).freeze
<!DOCTYPE html>

<html>

<head>
<title>a</title>
</head>

<body>
  </h1>
</body>
</html>
END

csv = (<<END).freeze
a,b,c
1,2,3
END

Capybara.app = lambda do |env|
  body = case env["PATH_INFO"]
  when '/csv'
    csv
  when '/short'
    "a\nb"
  when '/good'
    s.sub("</h1>", "")
  when '/redirect'
    return [303, {'Location'=>'/good'}, []]
  else
    s
  end

  [200, {'Content-Length'=>body.bytesize}, [body]]
end

describe 'capybara-validate_html5' do
  include Capybara::DSL

  it "should raise failed assertion for invalid HTML" do
    visit '/'
    e = proc{page.title}.must_raise(Capybara::HTML5ValidationError)
    e.message.must_include('invalid HTML on page returned for /, called from spec/capybara_validate_html5_spec.rb')
    e.message.must_include "isn't allowed here"
    e.message.must_include "Currently open tags: html, body."
    e.message.must_include "\n     9: <body>\n    10:   </h1>\n    11: </body>\n"
  end unless optional

  it "should raise failed assertion for error in first few lines of HTML" do
    visit '/short'
    e = proc{page.title}.must_raise(Capybara::HTML5ValidationError)
    e.message.must_include('invalid HTML on page returned for /short, called from spec/capybara_validate_html5_spec.rb')
    e.message.must_include "ERROR: Expected a doctype token"
    e.message.must_include "\n     1: a\n     2: b\n"
  end unless optional

  it "should raise for valid HTML" do
    visit '/good'
    page.title.must_equal 'a'
  end

  it "should handle redirects while on an invalid page" do
    visit '/'
    visit '/redirect'
    page.title.must_equal 'a'
  end

  it "should not raise failed assertion for invalid HTML if inside skip_html_validation" do
    visit '/'
    skip_html_validation{page.title}
    page.title.must_equal 'a'
  end

  it "should not attempt html validation if just accessing the body" do
    visit '/csv'
    page.body.must_equal csv
  end
end
