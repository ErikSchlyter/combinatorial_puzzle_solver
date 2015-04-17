require 'combinatorial_puzzle_solver'
require 'spec_helper'


module CombinatorialPuzzleSolver

  describe Puzzle do

    let!(:symbols) { (1..5).to_a }
    let!(:puzzle) { SingleRowPuzzle.new(symbols) }

    describe "#new" do

      it "should fail unless the block returns Constraint(s)" do
        expect { Puzzle.new(5, symbols) { "fubar" } }.to raise_error
        expect { Puzzle.new(5, symbols) { [] } }.to raise_error
        expect { puzzle }.to_not raise_error
      end
    end

    describe "#identifiers" do
      it "should return an array of all the identifiers" do
        expect(puzzle.identifiers).to be_an(Array)
        expect(puzzle.identifiers).to all( be_an(Identifier) )
      end
    end

    describe "#constraints" do
      it "should return an array of all the constraints" do
        expect(puzzle.constraints).to be_an(Array)
        expect(puzzle.constraints).to all( be_an(Constraint) )
      end
    end

    describe "#symbols" do
      it "should return an array of all the possible symbolsfor an identifier" do
        expect(puzzle.symbols).to be_an(Array)
        expect(puzzle.symbols).to match_array(symbols)
      end
    end

    describe "#resolve" do
      let!(:puzzle) { puzzle = TwoConstraintPuzzle.new }

      it "should return a SolutionSpace" do
        expect(puzzle.resolve).to be_a(SolutionSpace)
      end

      context "when puzzle is solvable" do
        it "should return a SolutionSpace that is resolved" do
          expect(puzzle.resolve.resolved?).to be true
        end
      end

      context "when the puzzle is unsolvable" do
        before {
          puzzle.identifiers[0].set!(1)
          puzzle.identifiers[1].set!(2)
          puzzle.identifiers[4].set!(3)
        }

        it "should return nil" do
          expect(puzzle.resolve).to be_nil
        end
      end
    end
  end
end

