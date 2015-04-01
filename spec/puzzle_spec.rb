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
  end


end

