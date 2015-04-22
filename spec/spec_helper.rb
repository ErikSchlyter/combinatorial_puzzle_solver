require 'combinatorial_puzzle_solver'

module CombinatorialPuzzleSolver

  class SingleRowPuzzle < Puzzle
    def initialize(values)
      super(values.size, values) {|identifiers| [ Constraint.new(identifiers) ] }
    end
  end

  # A test puzzle that consists of 5 identifiers and 2 constraints. The first
  # constraint includes identifier [0,1,2] and the second contains [2,3,4],
  # which means that identifier [2] overlap both constraints.
  class TwoConstraintPuzzle < Puzzle
    def initialize
      super(5, [1,2,3]){|identifiers|
        [ Constraint.new(identifiers[0..2]), Constraint.new(identifiers[2..4]) ]
      }
    end

    def to_s
      str = identifiers.collect{|identifier|
        (identifier.has_value?) ? identifier.value.to_s : " "
      }
      "{#{str[0]}#{str[1]}[#{str[2]}}#{str[3]}#{str[4]}]"
    end
  end
end

