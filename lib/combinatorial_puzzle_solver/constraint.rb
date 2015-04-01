
module CombinatorialPuzzleSolver

  # A set of identifiers that all should have unique values, like a row or
  # column in a Sudoku puzzle.
  class Constraint

    # @ return [String, nil] An optional label for diagnostic output
    attr_reader :label

    # @ return [Array<Identifier>] The identifiers that this constraint coverts.
    attr_reader :identifiers

    # Creates a constraint that states that the given identifiers can not
    # contain the same value.
    # @param identifiers  [Array<Identifiers>] the identifiers
    # @param label        [String] an optional label for diagnostic output
    def initialize(identifiers, label=nil)
      @identifiers = Array.new(identifiers)
      @label = label

      fail unless @identifiers.is_a?(Array)
      fail unless @identifiers.all?{|id| id.is_a?(Identifier) }

      @identifiers.each{|identifier| identifier.dependencies << self }
    end

    # Notifies identifiers if a value can only be set to that single identifier
    # wihtin the constraint.
    # @yieldparam identifier [Identifier] An Identifier that was resolved.
    # @yieldparam value [Object] The value that the identifier was resolved to.
    def resolve!
      possible_values.each{|value, identifiers|
        if identifiers.size == 1 then # this identifier is resolvable
          resolvable_identifier = identifiers.first
          unless resolvable_identifier.resolved? then

            yield resolvable_identifier, value if block_given?
            resolved = resolvable_identifier.must_be!(value)

            resolved.each{|resolved_id, resolved_value|
              yield resolved_id, resolved_value if block_given?
            }
          end
        end
      }
    end

    # All possible values that can be set within this constraint, each mapped to
    # the set of identifiers that can have that value without violating any
    # constraints.
    # @return [Map<Object,Set<Identifier>>] A map between each possible value
    #                                       and the set of identifiers that can
    #                                       have it.
    def possible_values
      values = Hash.new{|value,ids| value[ids] = Set.new }

      @identifiers.each{|identifier|
        identifier.possible_values.each{|value|
          values[value] << identifier
        }
      }

      values
    end

  end
end
