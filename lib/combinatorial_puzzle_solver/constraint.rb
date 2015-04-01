
module CombinatorialPuzzleSolver

  # A set of identifiers that all should have unique values, like a row or
  # column in a Sudoku puzzle.
  class Constraint

    # @ return [String, nil] An optional label for diagnostic output
    attr_reader :label

    # @ return [Array<Identifier>] The identifiers that this constraint coverts.
    attr_reader :identifiers

    # Creates a constraint that states that the given identifiers can not
    # contain the same value.
    # @param identifiers  [Array<Identifiers>] the identifiers
    # @param label        [String] an optional label for diagnostic output
    def initialize(identifiers, label=nil)
      @identifiers = Array.new(identifiers)
      @label = label

      fail unless @identifiers.is_a?(Array)
      fail unless @identifiers.all?{|id| id.is_a?(Identifier) }

      @identifiers.each{|identifier| identifier.dependencies << self }
    end
  end
end
