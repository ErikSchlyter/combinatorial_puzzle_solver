# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'combinatorial_puzzle_solver/version'

Gem::Specification.new do |spec|
  spec.name          = "combinatorial_puzzle_solver"
  spec.version       = CombinatorialPuzzleSolver::VERSION
  spec.authors       = ["Erik Schlyter"]
  spec.email         = ["erik@erisc.se"]

  spec.summary       = %q{A resolver of combinatorial number-placement puzzles, like Sudoku.}
  spec.description   = %q{A resolver of combinatorial number-placement puzzles, like Sudoku.}
  spec.homepage      = "https://github.com/ErikSchlyter/combinatorial_puzzle_solver"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-illustrate", "~> 0.1.3"

  spec.add_development_dependency "yard", "~>  0.8.7.6"
  spec.add_development_dependency "redcarpet", "~>  3.2.2"

end
