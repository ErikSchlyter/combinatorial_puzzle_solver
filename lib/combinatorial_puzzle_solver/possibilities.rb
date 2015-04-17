
module CombinatorialPuzzleSolver

  # A collection of the possible values an identifier can have. It is reduced by
  # invoking {#cannot_be!} and {#must_be!} until it only has one possible value, and
  # thus becomes {#resolved?}.
  class Possibilities < Array

    # Creates a set of possibilities for a specific identifier, which initially would
    # be all possible symbols of the puzzle.
    # @param solution_space [SolutionSpace] the solution space that this set belongs
    #                                       to.
    # @param identifier [Identifier] the identifier associated with this set of
    #                                possible values.
    def initialize(solution_space, identifier)
      @solution_space = solution_space
      @identifier = identifier

      super(identifier.puzzle.symbols) unless identifier.has_value?
    end

    # Reduce the possible values by stating that the identifier can only have a
    # certain value.
    #
    # @param value [Object] the only possible value the identifier can have.
    # @param resolvable [Hash<Identifier,Object>] an optional Hash to store all
    #                                             identifiers and values that becomes
    #                                             resolvable.
    # @return [Hash<Identifier,Object>] a Hash of identifiers that becomes
    #                                   resolvable because of this action.
    # @raise [Inconsistency] if the solution space becomes inconsistent without any
    #                        possible solution.
    def must_be!(value, resolvable=Hash.new)
      raise Inconsistency if @identifier.has_value? && @identifier.value != value
      raise Inconsistency unless include?(value)

      clear
      push(value)

      dependent_identifiers_cannot_be!(value, resolvable)
    end

    # Notifies dependent identifiers that they can't have a certain value.
    #
    # @param value [Object] a value that the dependent identifiers cannot have.
    # @param resolvable [Hash<Identifier,Object>] an optional Hash to store all
    #                                             identifiers and values that becomes
    #                                             resolvable.
    # @return [Hash<Identifier,Object>] the hash of identifiers that becomes
    #                                   resolvable because of this action.
    # @raise [Inconsistency] if the solution space becomes inconsistent without any
    #                        possible solution.
    def dependent_identifiers_cannot_be!(value, resolvable=Hash.new)
      @identifier.dependent_identifiers.each{|dependency|
        @solution_space[dependency].cannot_be!(value, resolvable)
      }
      resolvable
    end

    # Reduce the possible values by stating that the identifier cannot have a certain
    # value.
    #
    # @param value [Object] a value that the identifier cannot have.
    # @param resolvable [Hash<Identifier,Object>] an optional Hash to store all
    #                                             identifiers and values that becomes
    #                                             resolvable.
    # @return [Hash<Identifier,Object>] the hash of identifiers that becomes
    #                                   resolvable because of this action.
    # @raise [Inconsistency] if the solution space becomes inconsistent without any
    #                        possible solution.
    def cannot_be!(value, resolvable=Hash.new)
      raise Inconsistency if @identifier.value == value

      if delete(value) then
        raise Inconsistency if empty?
        resolvable[@identifier] = first if resolved?
      end
      resolvable
    end

    # @return [true,false] true if the identifier can only have one possible value,
    #                      false otherwise.
    def resolved?
       size == 1
    end
  end

end

