require "rake/clean"
require "rdoc/task"

CLEAN.include ["capybara-validate_html5-*.gem", "rdoc", "coverage"]

### Specs

desc "Run specs"
task :default=>:spec

desc "Run specs"
task :spec do
  sh "#{FileUtils::RUBY} #{'-w' if RUBY_VERSION >= '3'} #{'-W:strict_unused_block' if RUBY_VERSION >= '3.4'} spec/capybara_validate_html5_spec.rb"
end

desc "Run specs with coverage"
task :spec_cov do
  ENV['COVERAGE'] = '1'
  sh "#{FileUtils::RUBY} spec/capybara_validate_html5_spec.rb"
end

### RDoc

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += ["--quiet", "--line-numbers", "--inline-source", '--title', 'capybara-validate_html5: Validate HTML5 for each page parsed', '--main', 'README.rdoc']

  begin
    gem 'hanna'
    rdoc.options += ['-f', 'hanna']
  rescue Gem::LoadError
  end

  rdoc.rdoc_files.add %w"README.rdoc CHANGELOG MIT-LICENSE lib/**/*.rb"
end
