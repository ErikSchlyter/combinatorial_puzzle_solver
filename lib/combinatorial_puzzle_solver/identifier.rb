
module CombinatorialPuzzleSolver

  # Designates the smallest unit that should be mapped to a number, e.g. a cell
  # in a Sudoku puzzle.
  class Identifier
    # @return [Object, nil] the value that this identifier is assigned to, or nil.
    attr_reader :value

    # @return [Array<Constraint>] the constraints that affect this identifier
    attr_reader :constraints

    # @return [Puzzle] the puzzle that this identifier belongs to.
    attr_reader :puzzle

    # Creates an Identifier
    # @param puzzle [Puzzle] the puzzle this identifier belongs to.
    def initialize(puzzle)
      @puzzle = puzzle;
      @value = nil
      @constraints = []
    end

    # Sets the value for this identifier
    # @param value [Object] the value to set.
    def set!(value)
      @value = value
    end

    # @return [Array<Identifier>] all other identifiers that are covered by this
    #                             identifier's constraints.
    def dependent_identifiers
      @constraints.flatten.uniq - [self]
    end

    # @return [true,false] true if this identifier has a value, false otherwise.
    def has_value?
      !@value.nil?
    end

    # @return [String] a string representation of this identifier, which is defined
    #                  by  {Puzzle#identifier_to_s}.
    # @see Puzzle#identifier_to_s
    def to_s
      @puzzle.identifier_to_s(self)
    end

    # @return [String] a string representation of this identifier, which is defined
    #                  by  {Puzzle#inspect_identifier}.
    # @see Puzzle#identifier_to_s
    def inspect
      @puzzle.inspect_identifier(self)
    end
  end
end
