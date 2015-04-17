require "bundler/gem_tasks"
Bundler.setup

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format RSpec::Formatters::IllustratedDocumentationFormatter"
end

RSpec::Core::RakeTask.new(:html_spec) do |t|
  t.rspec_opts = "--format RSpec::Formatters::IllustratedHtmlFormatter --out ./doc/rspec-results.html"
end

require 'yard'
YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/**/*.rb', '-', 'doc/rspec-results.html' ]
end
task :doc => [:html_spec]

YARD::Rake::YardocTask.new(:list_undoc) do |t|
  t.stats_options = ['--list-undoc']
end

task :sanity_check => [:spec, :list_undoc]
task :test => :spec
task :default => :spec
