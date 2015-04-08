require 'rspec/illustrate'
require 'combinatorial_puzzle_solver'


module CombinatorialPuzzleSolver

  describe Sudoku do
    # Creates an array that shows which of the given groups each identifier belongs
    # to.
    # @param groups [Array<Array<Identifier>>] An array of arrays of identifiers
    # @return [Array<Fixnum>] an array of the indices if the identifiers in the given
    #                         groups.
    def identifier_indices_in(groups)
      sudoku.identifiers.collect{|identifier|
        groups.index{|group| group.include?(identifier) }
      }
    end

    # @return [String] a multiline string (matrix) that shows which of the given
    #                  groups (1..(groups.size)) each identifier belongs to.
    def identifiers_grouped_by(groups, row_size=sudoku.size)
      identifier_indices_in(groups).each_slice(row_size).collect{|row|
        row.collect{|identifier_index| identifier_index.next.to_s }.join
      }.join("\n")
    end

    let!(:sudoku) { Sudoku.new }

    describe "#rows" do
      it "should return an array of all identifiers grouped in rows." do
        expect(sudoku.rows).to be_a(Array)
        illustrate identifiers_grouped_by(sudoku.rows), :label=>"Rows"
      end
    end

    describe "#columns" do
      it "should return an array of all identifiers grouped in columns." do
        expect(sudoku.columns).to be_a(Array)
        illustrate identifiers_grouped_by(sudoku.columns), :label=>"Columns"
      end
    end

    describe "#squares" do
      it "should return an array of all identifiers grouped in squares" do
        expect(sudoku.columns).to be_a(Array)
        illustrate identifiers_grouped_by(sudoku.squares), :label=>"Squares"
      end
    end

    let(:puzzle_string) { "000|301|000
                           009|000|000
                           080|000|030
                           ---+---+---
                           000|004|980
                           007|120|500
                           200|090|170
                           ---+---+---
                           050|012|000
                           090|007|000
                           300|405|008".gsub(/ /, '')}

    describe "#scan" do
      it "should create a Sudoku puzzle and set the values" do
        illustrate puzzle_string, :label=>"Given the input string:"
        sudoku = Sudoku.scan(puzzle_string)

        illustrate sudoku.to_s, :label=>"The resulting puzzle:"
        expect(sudoku).to be_a(Sudoku)
        expect(sudoku.identifiers.count{|id| id.has_value?}).to eq(25)
      end
    end


    it "solves sudoku puzzles" do
      sudoku = Sudoku.scan(puzzle_string)
      illustrate sudoku.to_s, :label=>"Given the puzzle:"

      sudoku.resolve!

      sudoku.identifiers.each{|identifier|
        expect(identifier.resolved? || identifier.has_value?).to be true
        identifier.set!(identifier.possible_values.first) unless identifier.has_value?
      }

      expect(sudoku.resolved?).to be true
      illustrate sudoku.to_s, :label=>"When resolved:"
    end


  end

end

