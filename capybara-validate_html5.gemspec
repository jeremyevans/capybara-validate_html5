Gem::Specification.new do |s|
  s.name = 'capybara-validate_html5'
  s.version = '1.1.0'
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG", "MIT-LICENSE"]
  s.rdoc_options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'capybara-validate: Validate HTML5 for each page accessed', '--main', 'README.rdoc']
  s.license = "MIT"
  s.summary = "Validate HTML5 for each page accessed"
  s.author = "Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.homepage = "http://github.com/jeremyevans/capybara-validate_html5"
  s.files = %w(MIT-LICENSE CHANGELOG README.rdoc) + Dir["lib/**/*.rb"]
  s.description = <<END
capybara-validate validates the HTML5 for each page accessed, and
fails if there are any HTML5 parse errors on the page.  This makes
it easy to automatically test for HTML5 validity when running your
normal capybara test suite.
END
  s.metadata = {
    'bug_tracker_uri'   => 'https://github.com/jeremyevans/capybara-validate_html5/issues',
    'changelog_uri'     => 'https://github.com/jeremyevans/capybara-validate_html5/blob/master/CHANGELOG',
    'source_code_uri'   => 'https://github.com/jeremyevans/capybara-validate_html5',
  }

  s.add_dependency 'rack-test', '>= 0.6'
  s.add_dependency 'capybara'
  s.add_development_dependency 'minitest'
  s.add_development_dependency "minitest-global_expectations"
end
