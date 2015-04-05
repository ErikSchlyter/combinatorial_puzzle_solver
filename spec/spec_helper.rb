require 'combinatorial_puzzle_solver'

module CombinatorialPuzzleSolver

  class SingleRowPuzzle < Puzzle
    def initialize(values)
      super(values.size, values) {|identifiers| Constraint.new(identifiers) }
    end
  end

  # A test puzzle that consists of 6 identifiers and 2 constraints. The first
  # constraint includes identifier [0,1,2,3] and the second contains [2,3,4,5],
  # which means that identifiers [2,3] overlap.
  class TwoConstraintPuzzle < Puzzle
    def initialize
      super(5, [1,2,3]){|identifiers|
        [ Constraint.new(identifiers[0..2]), Constraint.new(identifiers[2..4]) ]
      }
    end
  end
end

