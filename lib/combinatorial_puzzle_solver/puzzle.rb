require 'set'

module CombinatorialPuzzleSolver

  # Base class for a combinatorial number-placement puzzle
  class Puzzle

    # @return [Array<Identifier>]
    attr_reader :identifiers

    # @return [Array<Constraint>]
    attr_reader :constraints

    # @return [Array] An array that contains all the possible values each
    #                 identifier can have.
    attr_reader :values

    # Creates a new puzzle.
    #
    # @param identifier_count [Fixnum] The number of identifiers in this puzzle
    # @param values [Array] The possible values each identifier can have.
    # @yield [identifiers] The block responsible for initiating the constraints.
    # @yieldparam [Array<Identifier>] identifiers
    # @yieldreturn [Array<Constraint>] The initialized constraints
    #
    def initialize(identifier_count, values, &constraint_block)

      @values = values.uniq
      @identifiers = Array.new(identifier_count) { Identifier.new(self) }

      fail "No block for initiating constraints given" unless block_given?
      @constraints = yield @identifiers
      @constraints = [@constraints] unless @constraints.is_a?(Array)

      fail "The constraint block returned 0 constraints" if @constraints.empty?
      unless @constraints.all?{|constraint| constraint.is_a?(Constraint)} then
        fail "The constraint block may only contain Constraint"
      end
    end

    # A string representation of a identifier, in the context of this puzzle.
    # @return [String] Default representation is '[index:value]'.
    def identifier_to_s(identifier)
      "[#{identifiers.index(identifier)}:#{identifier.value}]"
    end

  end

end
