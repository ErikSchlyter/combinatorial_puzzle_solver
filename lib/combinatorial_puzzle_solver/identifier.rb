
module CombinatorialPuzzleSolver

  # The current state of the puzzle has become inconsistent and unresolvable.
  class Inconsistency < RuntimeError
  end

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
    # @param value [Object] The value to set.
    # @raise [RuntimeError] If this identifier already has a value set.
    # @raise [Inconsistency] If this action makes the puzzle inconsistent.
    def set!(value)
      fail "Value for #{to_s} already set" unless @value.nil?
      @value = value
      @possible_values.clear
      dependent_identifiers.select{|identifier| identifier.cannot_be!(value)}
    end

    # All other identifiers that are covered by this identifier's constraints.
    # @return [Array<Identifier>]
    def dependent_identifiers
      @dependencies.collect{|constraint| constraint.identifiers}.flatten.uniq - [self]
    end

    # Notifies this identifier that it cannot have the given value, which will
    # reduce the set of possible values.
    # @param value [Object] The value that this identifier can't have
    # @return [true,false] true if the identifier becomes resolvable.
    # @raise [Inconsistency] If this action makes the puzzle inconsistent.
    def cannot_be!(value)
      raise Inconsistency if @value == value

      if @possible_values.delete(value) then
        raise Inconsistency if @value.nil? && @possible_values.empty?
        return resolved?
      end
      false
    end

    # Notifies that this identifier must be a certain value, which implies that
    # dependent identifiers can't have the same value.
    # @param value [Object] The value that this identifier must be set to.
    # @return [Array<Identifier>] The dependent identifiers that become
    #                             resolvable because of this action.
    def must_be!(value)
      @possible_values = [value]
      dependent_identifiers.select{|identifier| identifier.cannot_be!(value) }
    end

    # @return [true,false] True if set or only has one possible value.
    def resolved?
      @value != nil || @possible_values.size == 1
    end

    # @return [String] a string representation of this identifier, '[index:value]'.
    def to_s
      "[#{@puzzle.identifiers.index(self)}:#{value}]"
    end

    # Pushes the state of the identifier onto the given stack, which is useful
    # if you want to set new values or derive possibilities while being able to
    # revert.
    # @see pop_state
    # @param stack [Array] The stack to push the state onto.
    def push_state(stack)
      begin
        stack.push(@value.dup)
      rescue TypeError
        stack.push(@value)
      end
      stack.push(Array.new(@possible_values))
    end

    # Pops the state of the identifier from the given stack.
    # @see push_state
    # @param stack [Array] The stack to pop the state from.
    def pop_state(stack)
      @possible_values = stack.pop
      @value = stack.pop
    end

  end
end
