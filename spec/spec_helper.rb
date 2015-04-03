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
      super(6, [1,2,3,4]){|identifiers|
        [ Constraint.new(identifiers[0..3]), Constraint.new(identifiers[2..5]) ]
      }
    end
  end

  # A test puzzle consisting of n identifiers and n-1 constraints, where each
  # identifier can have 2 different values. The identifiers are chained together
  # with constraints as such: [0, 1], [1, 2], [2, 3] ... [n-1, n], which means
  # that if any identifier has a value the entire chain should be resolvable.
  class ChainConstraintPuzzle < Puzzle
    def initialize(size)
      super(size, [1,2]){|dentifiers|
        identifiers.each_cons(2).collect{|a,b| Constraint.new([a,b]) }
      }
    end
  end
end

