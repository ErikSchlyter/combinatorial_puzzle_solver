require "bundler/gem_tasks"
Bundler.setup

require 'rake/clean'
require 'yard'
require 'rspec/illustrate/yard'
require "rspec/core/rake_task"

desc "Execute tests"
RSpec::Core::RakeTask.new(:test)

desc "Execute RSpec and create a test report at ./doc/api.rspec."
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format RSpec::Formatters::YARD --out ./doc/api.rspec"
end

desc "Create documentation."
YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/**/*.rb', 'doc/api.rspec', '-', 'doc/api.rspec', 'doc/examples.md' ]
end
task :doc => [:spec, :examples]
CLEAN.include("doc")
CLEAN.include(".yardoc")

desc "Create example documentation."
require_relative 'example_puzzles/compile_examples'
task :examples => ['doc/examples.md']
file 'doc/examples.md' => FileList["example_puzzles/*"] do
  markdown = compile_examples_to_markdown(Dir.glob('example_puzzles/*.yaml'),2)
  File.write('doc/examples.md', markdown)
  $stderr.puts "examples ok!"
end

desc "List the undocumented code."
YARD::Rake::YardocTask.new(:list_undoc) do |t|
  t.stats_options = ['--list-undoc']
end

task :default => :doc

