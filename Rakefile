require "bundler/gem_tasks"
require 'rspec/illustrate/default_rake_targets'

desc "Create example documentation."
task :examples => ['tmp/examples.md']

require_relative 'example_puzzles/compile_examples'
file 'tmp/examples.md' => FileList["example_puzzles/*"] do
  markdown = compile_examples_to_markdown(Dir.glob('example_puzzles/*.yaml'),2)
  File.write('tmp/examples.md', markdown)
  $stderr.puts "examples ok!"
end

# remove the old doc-task defined in rspec/illustrate/default_rake_targets
Rake::Task['doc'].clear

desc "Create documentation."
YARD::Rake::YardocTask.new(:doc) do |t|
  t.files   = ['lib/**/*.rb', 'tmp/api.rspec', '-', 'tmp/api.rspec', 'tmp/examples.md' ]
end
task :doc => [:spec, :examples]

