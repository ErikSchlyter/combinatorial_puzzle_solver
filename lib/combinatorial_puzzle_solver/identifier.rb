
module CombinatorialPuzzleSolver

  # The current state of the puzzle has become inconsistent and unresolvable.
  class Inconsistency < RuntimeError
  end

  # Designates the smallest unit that should be mapped to a number, e.g. a cell
  # in a Sudoku puzzle.
  class Identifier
    # @return [Object, nil] the value that this identifier is set to, or nil.
    attr_reader :value

    # @return [Array<Constraint>] the constraints that affect this identifier
    attr_reader :dependencies

    # @return [Array] the values that this identifier can be set to without
    #                 violating any of its constraints.
    attr_reader :possible_values

    # Creates an Identifier
    # @param puzzle [Puzzle] the puzzle this identifier belongs to.
    def initialize(puzzle)
      @puzzle = puzzle;
      @value = nil
      @dependencies = []
      @possible_values = Array.new(puzzle.values)
    end

    # Sets the value for this identifier
    # @param value [Object] the value to set.
    # @raise [RuntimeError] if this identifier already has a value set.
    # @raise [Inconsistency] if this action makes the puzzle inconsistent.
    def set!(value)
      fail "Value for #{to_s} already set" unless @value.nil?
      @value = value
      @possible_values.clear
      dependent_identifiers_cannot_be!(value)
    end

    # Notifies dependent identifiers that they can't have the given value.
    # @param value [Object] The value that the identifiers cannot have.
    # @param resolved [Array<Identifier>] an optional array to store the identifiers
    #                                     that becomes resolvable. It will be created
    #                                     if not given.
    # @return [Array<Identifier>] the array of the identifiers that became resolvable
    #                             because of this action.
    # @raise [Inconsistency] if this action makes the puzzle inconsistent.
    # @see #dependent_identifiers
    # @see #cannot_be!
    def dependent_identifiers_cannot_be!(value, resolved=[])
      dependent_identifiers.each{|identifier| identifier.cannot_be!(value, resolved)}
      resolved
    end

    # @return [Array<Identifier>] all the identifiers that are covered by this
    #                             identifier's constraints.
    def dependent_identifiers
      @dependencies.collect{|constraint| constraint.identifiers}.flatten.uniq - [self]
    end

    # Notifies this identifier that it cannot have the given value, which will
    # reduce its set of possible values.
    # @param value [Object] the value that this identifier can't have
    # @param resolved [Array<Identifier>] an optional array to store the identifiers
    #                                     that becomes resolvable. It will be created
    #                                     if not given.
    # @return [Array<Identifier>] the array of the identifiers that became resolvable
    #                             because of this action.
    # @raise [Inconsistency] if this action makes the puzzle inconsistent.
    # @see #must_be!
    def cannot_be!(value, resolved=[])
      raise Inconsistency if @value == value

      if @possible_values.delete(value) then
        raise Inconsistency if @possible_values.empty?
        must_be!(@possible_values.first, resolved) if @possible_values.size == 1
      end
      resolved
    end

    # Notifies this identifier that it must have a certain value, which implies that
    # dependent identifiers can't have the same value.
    # @param value [Object] The only value that this identifier can have.
    # @param resolved [Array<Identifier>] an optional array to store the identifiers
    #                                     that becomes resolvable. It will be created
    #                                     if not given.
    # @return [Array<Identifier>] the array of the identifiers that became resolvable
    #                             because of this action.
    # @raise [Inconsistency] if this action makes the puzzle inconsistent.
    # @see #dependent_identifiers_cannot_be!
    def must_be!(value, resolved=[])
      @possible_values = [value]
      resolved << self
      dependent_identifiers_cannot_be!(value, resolved)
    end

    # @return [true,false] true if the identifier has a value or if it only has one
    #                      possible value, false otherwise.
    def resolved?
      @value != nil || @possible_values.size == 1
    end

    # @return [String] a string representation of this identifier, '[index:value]'.
    def to_s
      "[#{@puzzle.identifiers.index(self)}:#{value}]"
    end

    # @return [String] the identifier and its possible values as a string.
    def inspect
      "#{to_s} - #{@possible_values.inspect}"
    end

    # Pushes the state of the identifier onto the given stack, which is useful
    # if you want to set new values or derive possibilities while being able to
    # revert.
    # @see pop_state!
    # @param stack [Array] the stack to push the state onto.
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
    # @param stack [Array] the stack to pop the state from.
    def pop_state!(stack)
      @possible_values = stack.pop
      @value = stack.pop
    end

    # Pops a state from the given stack and discards it.
    # @param stack [Array] the stack to pop the state from.
    def pop_and_skip_state(stack)
      stack.pop
      stack.pop
    end

  end
end
