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

    describe "possible_values" do
      let!(:puzzle)     { SingleRowPuzzle.new([1,2,3]) }
      let!(:constraint) { puzzle.constraints.first }

      context "when the constraint's identifiers doesn't contain any value" do
        it "should map between all values and sets of all of identifiers" do
          expect(constraint.possible_values).to match(
            { 1 => puzzle.identifiers,
              2 => puzzle.identifiers,
              3 => puzzle.identifiers }
          )
        end
      end
      context "when one of the identifier has a value" do
        it "should return a Hash between all possible values and their identifiers" do
          puzzle.identifiers[0].set(3)
          expect(constraint.possible_values).to match(
            { 1 => puzzle.identifiers[1..2],
              2 => puzzle.identifiers[1..2] }
          )

        end
      end

    end
  end
end
