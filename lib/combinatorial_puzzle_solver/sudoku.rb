
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
    # It expects to find the correct amount of identifiers (81 for a 9x9 puzzle,
    # which would be a puzzle with dimension 3).
    #
    # @param string [String] the input string.
    # @param dimension [Fixnum] Dimension 2 implies a 4x4 puzzle, 3 implies 9x9.
    # @return [Sudoku] the parsed sudoku puzzle.
    def self.scan(string, dimension=3)
      sudoku = Sudoku.new(dimension)

      string.scan(/\d/).collect{|value| value.to_i}.each_with_index{|value, index|
        unless value == 0 then
          sudoku.identifiers[index].set!(value)
        end
      }
      sudoku
    end

    # Creates a new and empty sudoku puzzle, with all identifiers unassigned.
    # @param dimension [Fixnum] the dimension of the puzzle ('2' implies a 4x4 puzzle
    #                           and '3' implies a 9x9 puzzle).
    def initialize(dimension=3)
      @dimension = dimension
      @size = dimension*dimension
      super(@size*@size, (1..@size).to_a) {|identifier|
        (rows + columns + squares).collect{|group| Constraint.new(group) }
      }
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
      slices = @identifiers.each_slice(@dimension).each_slice(@dimension).to_a
      slices.transpose.flatten.each_slice(@size).to_a
    end

    # @return [String] a simple string representation of the sudoku puzzle.
    def to_s
      identifiers = @identifiers.collect{|id| (id.has_value?) ? id.value.to_s : " "}
      identifiers.each_slice(@size).collect{|row| row.join }.join("\n")
    end
  end

end
