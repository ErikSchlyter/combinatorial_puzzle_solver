require 'set'

module CombinatorialPuzzleSolver

  # Base class for a combinatorial number-placement puzzle
  class Puzzle

    # @return [Array<Identifier>]
    attr_reader :identifiers

    # @return [Array<Constraint>]
    attr_reader :constraints

    # @return [Array] an array that contains all the possible values each
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

      @state_stack = []
    end

    # Pushes the entire state of the puzzle to a stack, which means you can set
    # values and resolve possibilities and then just pop the state to undo all
    # actions.
    # @see pop_state!
    def push_state
      @identifiers.each{|identifier| identifier.push_state(@state_stack) }
    end

    # Pops the entire state of the puzzle from the stack
    # @raise [RuntimeError] if the stack is empty.
    # @see push_state
    def pop_state!
      fail "Stack is empty" if @state_stack.empty?
      @identifiers.reverse_each{|identifier| identifier.pop_state!(@state_stack) }
    end

    # Pops a state from the stack and discards it.
    # @raise [RuntimeError] if the stack is empty.
    def pop_and_skip_state!
      fail "Stack is empty" if @state_stack.empty?
      @identifiers.each{|identifier| identifier.pop_and_skip_state(@state_stack) }
    end

    # Tries to resolve all constraints until none of them yield new solutions.
    # @param solutions [Hash<Identifier,Object>] an optional hash to store the
    #                                            identifiers that becomes resolved.
    #                                            It will be created if not given.
    # @return [Hash<Identifier,Object>] the hash of identifiers that becomes
    #                                   resolvable because of this action.
    # @raise [Inconsistency] if this action makes the puzzle inconsistent.
    def resolve_constraints!(solutions = {})
      loop do
        found_any = false

        @constraints.each{|constraint|
          new_solutions = constraint.resolve!
          unless new_solutions.empty? then
            found_any = true
            solutions.merge!(new_solutions)
          end
        }
        break unless found_any
      end
      solutions
    end

    # Solves the puzzle by resolving all constraints, and tries to {#resolve_with!}
    # the unresolved identifiers recursively if constraint resolution is not enough
    # to solve the puzzle.
    #
    # Any trial and error attempt that fails during a call to {#resolve_with!} will
    # be yielded with identifier and value.
    # @param solutions [Hash<Identifier,Object>] an optional hash to store the
    #                                            identifiers that becomes resolved.
    #                                            It will be created if not given.
    # @return [Hash<Identifier,Object>] the hash of identifiers that becomes
    #                                   resolved because of this action.
    # @yieldparam identifier [Identifier] any identifier that was tried and failed.
    # @yieldparam value [Object] any value that was tried and failed.
    # @see #resolve_with!
    def resolve!(solutions={}, &fail_block)
      begin
        new_solutions = resolve_constraints!

        unresolved_identifiers.each{|identifier|
          while !identifier.resolved? do
            maybe_value = identifier.possible_values.first

            if resolve_with!(identifier, maybe_value, new_solutions, &fail_block) then
              return solutions.merge!(new_solutions)
            else
              identifier.cannot_be!(maybe_value, new_solutions)
              resolve_constraints!(new_solutions)
            end
          end
        }
      rescue Inconsistency
      end

      solutions
    end

    # Tries to solve the puzzle recursively by invoking #resolve! with the assumption
    # that the given value is the only value the identifier can have.
    #
    # If the puzzle becomes unsolvable it returns false and the state is reverted.
    # If a solution is found it returns the resolved identifiers, and the puzzle is
    # left in the state of the accepted solution.
    #
    # Any attempt that fails will be yielded with identifier and value.
    # @param identifier [Identifier] the identifier to try.
    # @param value [Object] the value to try.
    # @param solutions [Hash<Identifier,Object>] an optional hash to store the
    #                                            identifiers that becomes resolved.
    #                                            It will be created if not given.
    # @return [Hash<Identifier,Object>, false] the resolved identifiers, or false if
    #                                          the puzzle becomes unsolvable.
    # @yieldparam identifier [Identifier] any identifier that was tried and failed.
    # @yieldparam value [Object] any value that was tried and failed.
    # @see #resolve!
    def resolve_with!(identifier, value, solutions={}, &fail_block)
      push_state
      begin
        new_solutions = identifier.must_be!(value) # might throw Inconsistency
        resolve!(new_solutions, &fail_block)

        if resolved? then
          pop_and_skip_state!
          return solutions.merge!(new_solutions)
        end

      rescue Inconsistency
      end

      yield identifier, value if block_given?
      pop_state!

      false
    end

    # @return [Array<Identifier>] the identifiers that are not yet resolved.
    # @see Identifier#resolved?
    def unresolved_identifiers
      @identifiers.select{|identifier| identifier.unresolved? }
    end

    # @return [true,false] true if all identifiers have values or have been resolved.
    def resolved?
      @identifiers.all?{|identifier| identifier.has_value? || identifier.resolved? }
    end

    # @return [String] identifiers and constraints as a string representation.
    # @see Identifier#inspect
    # @see Constraint#inspect
    def inspect
      (@identifiers + @constraints).collect{|obj| obj.inspect }.join("\n")
    end
  end
end
