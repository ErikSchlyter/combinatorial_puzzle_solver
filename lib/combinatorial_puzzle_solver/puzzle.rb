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
    def resolved_solution_space
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
      "[#{identifiers.index(identifier)}]"
    end

    # @return [String] a string representation of an identifier (including value), in
    #                  the context of this puzzle.
    def inspect_identifier(identifier)
      if identifier.has_value? then
        identifier_to_s(identifier) << "=#{identifier.value.to_s}"
      else
        identifier_to_s(identifier)
      end
    end

    # Sets all identifiers to the value they are resolved to.
    # @param solution_space [SolutionSpace]
    def set_resolved_identifiers!(solution_space)
      solution_space.resolved_identifiers.each{|identifier, value|
        identifier.set!(value)
      }
    end

    # Resolves a puzzle while writing diagnostic output to given streams.
    #
    # @param trial_and_error [Boolean] whether it should resort to trial and error if
    #                                  a complete solution cannot be resolved.
    # @param steps [Fixnum] how many steps it will perform before aborting (or 0).
    # @param output [Hash] a collection of output streams for diagnostic purposes.
    # @return [true,false] whether the puzzle was completely resolved or not.
    # @raise [Inconsistency] if the solution space becomes inconsistent without any
    #                         possible solution.
    def resolve!(trial_and_error=true, steps=0, output={})

      # print the parsed puzzle
      output[:parsed_stream].puts to_s << "\n\n" if output[:parsed_stream]

      step_count = 0

      solution = SolutionSpace.new(self)
      solution.resolve!(solution.resolved_identifiers){|x, identifier, value|

        # print the resolved step
        identifier.set!(value)
        output[:steps_stream].puts identifier.inspect if output[:steps_stream]

        # print the entire board
        output[:puzzle_stream].puts to_s << "\n\n" if output[:puzzle_stream]

        step_count += 1
        step_count != steps
      }

      # brute force with trial and error unless we only want the resolution steps
      brute_forced = solution.resolve_by_trial_and_error! if trial_and_error
      solution = brute_forced unless brute_forced.nil?

      # print the result
      set_resolved_identifiers!(solution)
      output[:result_stream].puts to_s << "\n\n" if output[:result_stream]

      solution.resolved?
    end

  end
end
