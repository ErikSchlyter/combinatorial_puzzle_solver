require "bundler/gem_tasks"
Bundler.setup

desc "Execute RSpec with default formatter"
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format RSpec::Formatters::IllustratedDocumentationFormatter"
end

desc "Execute RSpec with HTML formatter"
# RSpec - HTML output
RSpec::Core::RakeTask.new(:html_spec) do |t|
  t.rspec_opts = "--format RSpec::Formatters::IllustratedHtmlFormatter --out ./doc/rspec-results.html"
end

desc "Generate API documentation."
require 'yard'
YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/**/*.rb', '-', 'doc/rspec-results.html', 'doc/examples.md' ]
end
task :doc => [:html_spec, :examples]

desc "List the undocumented code."
YARD::Rake::YardocTask.new(:list_undoc) do |t|
  t.stats_options = ['--list-undoc']
end

# Generate examples and documentation
require_relative 'example_puzzles/compile_examples'
task :examples => ['doc/examples.md']
file 'doc/examples.md' => FileList["example_puzzles/*"] do
  markdown = compile_examples_to_markdown(Dir.glob('example_puzzles/*.yaml'),2)
  File.write('doc/examples.md', markdown)
  $stderr.puts "examples ok!"
end


task :test => [:spec, :examples]
task :default => :doc

