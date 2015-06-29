
module CombinatorialPuzzleSolver


  # A sudoku puzzle.
  #
  # A puzzle with dimension 3 implies the standard 9x9 puzzle, whereas dimension 2
  # implies a 4x4 puzzle.
  class Sudoku < Puzzle

    # @return [Fixnum] the width/height of the sudoku board (9 for a 9x9 puzzle).
    attr_reader :size

    # Parses a string where 1-9 are interpreted as values and 0 is interpreted as
    # unassigned, whereas all other characters (including whitespaces) are
    # discarded.
    #
    # @param string [String] the input string.
    # @param dimension [Fixnum] Dimension 2 implies a 4x4 puzzle, 3 implies 9x9.
    # @yieldparam sudoku [Sudoku] each parsed sudoku puzzle.
    # @return [Array[Sudoku]] the parsed sudoku puzzles.
    # @raise [RuntimeError] if the parsed digits don't match up to even puzzles.
    def self.scan(string, dimension=3)
      digits = string.scan(/\d/).collect{|value| value.to_i}
      size = dimension**4
      digits.each_slice(size).collect{|digits|
        puzzle = Sudoku.new(dimension, digits)
        yield puzzle if block_given?
        puzzle
      }
    end

    # Creates a new and empty sudoku puzzle, with all identifiers unassigned.
    # @param dimension [Fixnum] the dimension of the puzzle ('2' implies a 4x4 puzzle
    #                           and '3' implies a 9x9 puzzle).
    # @param digits [Array[Fixnum]] an optional array of digits, where each digit
    #                               corresponds to an identifier's value from 0 to 9.
    # @raise [RuntimeError] if the digits array (if given) is of incorrect size.
    def initialize(dimension=3, digits=[])
      @dimension = dimension
      @size = dimension*dimension
      super(@size*@size, (1..@size).to_a) {|identifier|
        (rows + columns + squares).collect{|group| Constraint.new(group) }
      }

      unless digits.empty? then
        unless digits.size == @size*@size then
          error_msg = "Parsed #{digits.size} digits instead of #{@size*@size})."
          raise RuntimeError.new(error_msg)
        end

        digits.each_with_index{|value, index|
          identifiers[index].set!(value) unless value == 0
        }
      end
    end

    # @return [Array<Array<Identifier>>] the identifiers grouped by rows
    def rows
      @identifiers.each_slice(@size).to_a
    end

    # @return [Array<Array<Identifier>>] the identifiers grouped by columns
    def columns
      rows.transpose
    end

    # @return [Array<Array<Identifier>>] the identifiers grouped by squares
    def squares
      slices = columns.flatten.each_slice(@dimension).each_slice(@dimension).to_a
      slices.transpose.flatten.each_slice(@size).to_a
    end

    # @return [String] a simple string representation of the sudoku puzzle.
    def to_s
      horizontal = "\n#{Array.new(@dimension){"-" * (@dimension*2-1) }.join("+")}\n"
      separators = [" ", "|", "\n", horizontal]

      values = @identifiers.collect{|id| (id.has_value?) ? id.value.to_s : " "}
      separators.each{|separator|
        values = values.each_slice(@dimension).collect{|s| s.join(separator) }
      }
      values.join
    end

    # @return [String] a string representation of an identifier, which would be
    #                  "[row,column]"
    def identifier_to_s(identifier)
      index = identifiers.index(identifier)
      "[#{index / size + 1},#{index % size + 1}]"
    end


  end
end
