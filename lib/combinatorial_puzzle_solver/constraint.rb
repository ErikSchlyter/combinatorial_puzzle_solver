
module CombinatorialPuzzleSolver

  # A set of identifiers that all should have unique values, like a row or
  # column in a Sudoku puzzle.
  class Constraint

    # @ return [Array<Identifier>] The identifiers that this constraint covers.
    attr_reader :identifiers

    # Creates a constraint that states that the given identifiers can not
    # contain the same value. Each of them must be unique.
    # @param identifiers  [Array<Identifiers>] the identifiers
    def initialize(identifiers)
      @identifiers = Array.new(identifiers)

      fail unless @identifiers.is_a?(Array)
      fail unless @identifiers.all?{|id| id.is_a?(Identifier) }

      @identifiers.each{|identifier| identifier.dependencies << self }
    end

    # Iterates all the possible values that can be set within this constraint, and
    # resolves those values that can only be assign to a single identifier.
    #
    # @return [Hash<Identifier,Object>] the identifiers that was resolved
    # @raise [Inconsistency] if this action makes the puzzle inconsistent.
    # @see #possible_values
    # @see Identifier#must_be!
    def resolve!
      solutions = {}

      possible_values.each{|value, identifiers|
        if identifiers.size == 1 then # this identifier is resolvable
          resolvable_identifier = identifiers.first
          unless resolvable_identifier.resolved? then

            solutions[resolvable_identifier] = value
            resolvable_identifier.must_be!(value).each{|identifier|
              solutions[identifier] = identifier.possible_values.first
            }
          end
        end
      }

      solutions
    end

    # All possible values that can be set within this constraint, each mapped to
    # the set of identifiers that can have that value without violating any
    # constraints.
    # @return [Hash<Object,Set<Identifier>>] a map between each possible value and
    #                                        the set of identifiers that can have it.
    def possible_values
      values = Hash.new{|value,ids| value[ids] = Set.new }

      @identifiers.each{|identifier|
        identifier.possible_values.each{|value|
          values[value] << identifier
        }
      }

      values
    end

    # @return [String] the covered identifiers as a string.
    def inspect
      "{ #{@identifiers.collect{|id| id.to_s}.join(', ')} }"
    end

  end
end
