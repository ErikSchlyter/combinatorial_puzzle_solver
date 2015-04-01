
module CombinatorialPuzzleSolver

  # Designates the smallest unit that should be mapped to a number, e.g. a cell
  # in a Sudoku puzzle.
  class Identifier
    # @ return [Object, nil] The value that this identifier is set to, or nil.
    attr_reader :value

    # @return [Array<Constraint>] The constraints that affect this identifier
    attr_reader :dependencies

    # @return [Array] The values that this identifier can be set to without
    #                 violating any of its constraints.
    attr_reader :possible_values

    # Creates an Identifier
    # @param puzzle [Puzzle] The puzzle
    def initialize(puzzle)
      @puzzle = puzzle;
      @value = nil
      @dependencies = []
      @possible_values = Array.new(puzzle.values)
    end

    # Sets the value for this identifier
    def set(value)
      fail "Value for #{to_s} already set" unless @value.nil?
      @value = value
      @possible_values.clear
      dependent_identifiers.select{|identifier| identifier.cannot_set!(value)}
    end

    # All other identifiers that are coverted by this identifier's constraints.
    # @return [Array<Identifier>]
    def dependent_identifiers
      @dependencies.collect{|constraint| constraint.identifiers}.flatten.uniq - [self]
    end

    # Notifies this identifier that it cannot have the given value, which will
    # reduce the set of possible values.
    # @param value [Object] The value that this identifier can't have
    # @return [true,false] true if the identifier becomes resolvable, which
    #                      means that its set of possible values now only
    #                      contain one single value.
    def cannot_set!(value)
      @possible_values.delete(value)

      @possible_values.size == 1
    end

    # @return [String] a string representation of this identifier
    def to_s
      @puzzle.identifier_to_s(self)
    end
  end
end
