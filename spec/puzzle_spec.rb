require 'rspec/illustrate'
require 'combinatorial_puzzle_solver'
require 'spec_helper'


module CombinatorialPuzzleSolver

  describe Puzzle do

    let!(:values) { (1..5).to_a }
    let!(:puzzle) { SingleRowPuzzle.new(values) }

    describe "#new" do

      it "should fail unless the block returns Constraint(s)" do
        expect { Puzzle.new(5, values) { "fubar" } }.to raise_error
        expect { Puzzle.new(5, values) { [] } }.to raise_error
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

    describe "#values" do
      it "should return an array of all the possible values for an identifier" do
        expect(puzzle.values).to be_an(Array)
        expect(puzzle.values).to match_array(values)
      end
    end

    describe "push and pop states" do
      it "store the state on the stack and be able to retrieve it" do
        puzzle.identifiers[0].cannot_be!(2)
        puzzle.identifiers[0].cannot_be!(3)

        puzzle.push_state
        puzzle.identifiers[0].set!(1)
        puzzle.pop_state

        expect(puzzle.identifiers[0].value).to be_nil
        expect(puzzle.identifiers[0].possible_values).to match_array([1,4,5])
      end
    end

    describe "resolve_constraints!" do
      it "should resolve all constraints and return a Hash of resolved identifiers" do
        puzzle = TwoConstraintPuzzle.new
        puzzle.identifiers[0].cannot_be!(1)
        puzzle.identifiers[1].cannot_be!(1)
        puzzle.identifiers[3].cannot_be!(2)

        solutions = puzzle.resolve_constraints!

        expect(solutions).to match({
          puzzle.identifiers[2] => 1,
          puzzle.identifiers[3] => 3,
          puzzle.identifiers[4] => 2
        })
      end
    end
  end


end

