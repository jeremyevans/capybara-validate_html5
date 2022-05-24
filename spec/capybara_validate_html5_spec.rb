ENV['MT_NO_PLUGINS'] = '1' # Work around stupid autoloading of plugins
gem 'minitest'
require 'minitest/global_expectations/autorun'
require 'capybara'
require 'capybara/dsl'
begin
  require_relative '../lib/capybara/validate_html5'
rescue LoadError
  optional = true
  require_relative '../lib/capybara/optionally_validate_html5'
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
  if env["PATH_INFO"] == '/csv'
    [200, {'Content-Type'=>'text/csv', 'Content-Length'=>csv.length}, [csv]]
  else
    [200, {'Content-Type'=>'text/html', 'Content-Length'=>s.length}, [s]]
  end
end

describe 'capybara-validate_html5' do
  include Capybara::DSL

  it "should raise failed assertion for invalid HTML" do
    visit '/'
    e = proc{page.title}.must_raise(Minitest::Assertion)
    e.message.must_include('invalid HTML on page returned for /, called from spec/capybara_validate_html5_spec.rb')
    e.message.must_include "\n<body>\n  </h1>\n</body>\n"
    e.message.must_include 'Nokogiri::XML::SyntaxError'
    e.message.must_include "ERROR: That tag isn't allowed here  Currently open tags: html, body."
  end unless optional

  it "should raise failed assertion for invalid HTML if inside skip_html_validation" do
    visit '/'
    skip_html_validation{page.title}
    page.title.must_equal 'a'
  end

  it "should not attempt html validation if just accessing the body" do
    visit '/csv'
    page.body.must_equal csv
  end
end
