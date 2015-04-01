require 'rspec/illustrate'
require 'combinatorial_puzzle_solver'


module CombinatorialPuzzleSolver

  describe Constraint do
    describe "#new" do
      it "should fail unless given a list of Identifiers" do
        expect{ Constraint.new(["I am error"]) }.to raise_error
      end
    end

    describe "#label" do
      it "returns a diagnostic string that represents this constraint." do
        puzzle = SingleRowPuzzle.new([1,2,3])
        identifiers = puzzle.identifiers

        constraint = Constraint.new(identifiers, "some debug label")

        expect(constraint.label).to match("some debug label")
      end
    end
  end
end
