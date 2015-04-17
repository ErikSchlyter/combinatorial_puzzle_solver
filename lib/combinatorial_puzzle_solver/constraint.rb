
module CombinatorialPuzzleSolver

  # A collection of identifiers that all should have unique values, like a row or a
  # column in a Sudoku puzzle.
  class Constraint < Array

    def initialize(identifiers)
      super(identifiers)
      fail unless identifiers.is_a?(Array)
      identifiers.each{|id| fail unless id.is_a?(Identifier)}

      each{|identifier| identifier.constraints << self }
    end

    # Iterates all possible values that can be set within this constraint, and
    # when a value can only be placed within that specific identifier.
    #
    # @param solution_space [SolutionSpace] the mapping between the puzzle's
    #                                       identifiers and the values they can have.
    # @param resolvable [Hash<Identifier,Object>] an optional Hash to store all
    #                                             identifiers and values that becomes
    #                                             resolvable.
    # @return [Hash<Identifier,Object>] the identifiers that can be resolved, mapped
    #                                   to the only value they can have.
    def resolvable_identifiers(solution_space, resolvable=Hash.new)
      possible_values(solution_space).each{|value, identifiers|
        if identifiers.size == 1 then
          resolved_identifier = identifiers.first
          unless solution_space[resolved_identifier].resolved? then
            resolvable[resolved_identifier] = value
          end
        end
      }
      resolvable
    end

    # @param solution_space [SolutionSpace] the mapping between the puzzle's
    #                                       identifiers and the values they can have.
    # @return [Hash<Object,Set<Identifier>>] a map between each possible value within
    #                                        this constraint and the set of
    #                                        identifiers that can have them.
    def possible_values(solution_space)
      values = Hash.new{|value,ids| value[ids] = Set.new }

      each{|identifier|
        solution_space[identifier].each{|value|
          values[value] << identifier
        }
      }
      values
    end
  end
end
