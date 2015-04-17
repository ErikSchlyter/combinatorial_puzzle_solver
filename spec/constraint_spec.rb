require 'rspec/illustrate'
require 'combinatorial_puzzle_solver'


module CombinatorialPuzzleSolver
  describe Constraint do
    let!(:puzzle)     { SingleRowPuzzle.new([1,2,3]) }
    let!(:constraint) { puzzle.constraints.first }
    let!(:solution_space) { SolutionSpace.new(puzzle) }

    it "is an array" do
      expect(constraint).to be_a(Constraint)
      expect(constraint).to be_a(Array)
    end

    describe "#possible_values" do
      it "should return a Hash" do
        expect(constraint.possible_values(solution_space)).to be_a(Hash)
      end

      it "should contain each value, and the identifiers that can have them." do
        puzzle.identifiers[0].set!(1)
        solution_space = SolutionSpace.new(puzzle)

        possible_values = constraint.possible_values(solution_space)

        expect(possible_values).to match({2 => puzzle.identifiers[1..2],
                                          3 => puzzle.identifiers[1..2] })
      end
    end

    describe "#resolvable_identifiers" do
      it "should return a Hash" do
        expect(constraint.resolvable_identifiers(solution_space)).to be_a(Hash)
      end

      it "should return the identifiers mapped to their resolved value" do
        solution_space[puzzle.identifiers[0]].cannot_be!(1)
        solution_space[puzzle.identifiers[1]].cannot_be!(1)

        resolved = constraint.resolvable_identifiers(solution_space)

        expect(resolved).to match({puzzle.identifiers[2] => 1})
      end
    end
  end
end
