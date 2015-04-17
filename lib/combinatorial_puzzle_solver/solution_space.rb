
module CombinatorialPuzzleSolver

  # A mapping between each identifier of a puzzle and their possible values.
  class SolutionSpace < Hash

    # @return [Puzzle] the Puzzle that this solution space is associated with.
    attr_reader :puzzle

    # Creates a solution space for a given puzzle.
    # @param puzzle [Puzzle,SolutionSpace] the puzzle that this solution space is
    #                                      based on, or a clone if a SolutionSpace is
    #                                      given.
    def initialize(puzzle)
      if puzzle.is_a?(Puzzle) then
        @puzzle = puzzle
        @puzzle.identifiers.each{|identifier|
          self[identifier] = Possibilities.new(self, identifier)
        }

        select{|identifier| identifier.has_value? }.each{|identifier, possibilities|
          possibilities.dependent_identifiers_cannot_be!(identifier.value)
        }
      elsif puzzle.is_a?(SolutionSpace)
        puzzle.each{|identifier, possibilities|
          clone = Possibilities.new(self, identifier)
          clone.clear
          clone.concat(possibilities)
          self[identifier] = clone
        }
        @puzzle = puzzle.puzzle
      end
    end

    # @return [Hash<Identifier,Object>] a Hash of all identifiers that are resolved,
    #                                   mapped to the value they are resolved to.
    def resolved_identifiers
      resolved = {}
      each{|identifier, possibilities|
        if !identifier.has_value? && possibilities.resolved? then
          resolved[identifier] = possibilities.first
        end
      }
      resolved
    end

    # @return [Hash<Identifier,Possibilities>] the unresolved identifiers and their
    #                                          possible values.
    def unresolved_identifiers
      select{|identifier, possibilities|
        !identifier.has_value? && !possibilities.resolved?
      }
    end

    # @return [Hash<Identifier,Object>] a Hash of all identifiers that can be
    #                                   resolved by iterating possible values of each
    #                                   constraint.
    def resolvable_from_constraints
      resolvable=Hash.new
      @puzzle.constraints.each{|constraint|
        constraint.resolvable_identifiers(self, resolvable)
      }
      resolvable
    end

    # Resolves the given implications and the new implications they yield (including
    # those resolved from constraints, if no implications are given) until no more
    # identifiers can be resolved.
    #
    # If the solution space does not become {#resolved?} by this, it is necessary to
    # {#resolve_by_trial_and_error!} to find a complete solution.
    #
    # If a block is given it will yield the solution space with the corresponding
    # identifier and value before each time a resolution is made
    # ({Possibilities#must_be!}), and it will abort unless the block returns true.
    #
    # @param implications [Hash<Identifier,Object>] a mapping between identifiers and
    #                                               their assumed value.
    # @yieldparam solution_space [SolutionSpace] the solution space in the state
    #                                            right before a resolution is made.
    # @yieldparam identifier [Identifier] an identifier that is resolved.
    # @yieldparam value [Object] the value the identifier is resolved to.
    # @yieldreturn [true,nil] the resolution will abort unless the block returns true
    #                         for each identifier that is resolved.
    # @return [true,false] true if the solution space became completely resolved.
    # @raise [Inconsistency] if the solution space becomes inconsistent without any
    #                         possible solution.
    def resolve!(implications)

      loop do
        resolvable = Hash.new

        implications.each{|identifier, value|
          if block_given? then
            return false unless yield(self, identifier, value) == true
          end
          self[identifier].must_be!(value, resolvable)
        }

        if resolvable.empty? then
          implications = resolvable_from_constraints
        else
          implications = resolvable
        end


        break if implications.empty?
      end

      resolved?
    end

    # Iterates the possible values of unresolved identifiers and returns the solution
    # space for the first attempt that yields a complete solution. It will return
    # itself if it becomes resolved by eliminating the attempts that failed.
    #
    # @return [SolutionSpace] a solution space that is completely resolved
    # @raise [Inconsistency] if no complete solution is found.
    def resolve_by_trial_and_error!
      unresolved_identifiers.each{|identifier, possibilities|
        until possibilities.resolved? do
          maybe_value = possibilities.first
          maybe_solution = try_resolve_with(identifier, maybe_value)
          return maybe_solution unless maybe_solution.nil?

          resolve!(self[identifier].cannot_be!(maybe_value))
        end
      }

      self
    end

    # Creates a clone of the solution space and tries to solve it with the assumption
    # that the given identifier has the given value.
    # @return [SolutionSpace, nil] a solution space that is completely resolved, or
    #                              nil if no complete solution was found.
    def try_resolve_with(identifier, value)
      possible_solution_space = SolutionSpace.new(self)
      assumption = {identifier => value}

      begin
        if possible_solution_space.resolve!(assumption) then
          return possible_solution_space
        else
          return possible_solution_space.resolve_by_trial_and_error!
        end
      rescue Inconsistency
        return nil
      end
    end

    # @return [true, false] true if all identifiers have been resolved.
    def resolved?
      all?{|identifier,possibilities|
        identifier.has_value? || possibilities.resolved?
      }
    end
  end
end
