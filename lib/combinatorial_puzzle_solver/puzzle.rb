require 'set'

module CombinatorialPuzzleSolver

  # Base class for a combinatorial number-placement puzzle
  class Puzzle

    # @return [Array<Identifier>] the identifiers of this puzzle.
    attr_reader :identifiers

    # @return [Array<Constraint>] the constraints of this puzzle.
    attr_reader :constraints

    # @return [Array] an array that contains all the possible values each
    #                 identifier can have.
    attr_reader :symbols

    # Creates a new puzzle.
    #
    # @param identifier_count [Fixnum] The number of identifiers in this puzzle
    # @param symbols [Array] The possible values each identifier can have.
    # @yieldparam identifiers [Array<Identifier>] the identifiers of this puzzle.
    # @yieldreturn [Array<Constraint>] The initialized constraints
    #
    def initialize(identifier_count, symbols, &constraint_block)

      @symbols = symbols.uniq
      @identifiers = Array.new(identifier_count) { Identifier.new(self) }

      fail "No block for initiating constraints given" unless block_given?
      @constraints = yield @identifiers

      fail "The constraint block returned 0 constraints" if @constraints.empty?
      unless @constraints.all?{|constraint| constraint.is_a?(Constraint)} then
        fail "The constraint block may only contain Constraint"
      end
    end

    # @return [SolutionSpace,nil] the resolved solution space for this puzzle, or nil
    #                             if the puzzle doesn't have any solution.
    def resolve
      begin
        solution_space = SolutionSpace.new(self)
        solution_space.resolve!(solution_space.resolved_identifiers)
        return solution_space.resolve_by_trial_and_error!
      rescue Inconsistency
        nil
      end
    end

    # @return [String] identifiers and constraints as a string representation.
    # @see Identifier#inspect
    # @see Constraint#inspect
    def inspect
      (@identifiers + @constraints).collect{|obj| obj.inspect }.join("\n")
    end

    # @return [String] a string representation of an identifier, in the context of
    #                  this puzzle.
    def identifier_to_s(identifier)
      "\##{identifiers.index(identifier)}"
    end

    # @return [String] a string representation of an identifier (including value), in
    #                  the context of this puzzle.
    def inspect_identifier(identifier)
      if identifier.has_value? then
        identifier_to_s(identifier) << "(#{identifier.value})"
      else
        identifier_to_s(identifier)
      end
    end
  end
end
