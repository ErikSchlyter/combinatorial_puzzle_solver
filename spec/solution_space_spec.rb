require 'rspec/illustrate'
require 'combinatorial_puzzle_solver'


module CombinatorialPuzzleSolver

  describe SolutionSpace do
    let!(:values) { (1..5).to_a }
    let!(:puzzle) { SingleRowPuzzle.new(values) }
    let!(:identifiers) { puzzle.identifiers }
    let!(:solution_space) { SolutionSpace.new(puzzle) }

    describe "#new" do
      it "is a Hash mapping between identifiers and their possible values" do
        expect(solution_space.keys).to all( be_an(Identifier) )
        expect(solution_space.values).to all( be_an(Possibilities) )
      end

      it "creates a clone if another SolutionSpace is given as argument" do
        other = SolutionSpace.new(solution_space)

        expect(other.object_id).to_not eq(solution_space.object_id)
        expect(other).to match(solution_space)
      end
    end

    describe "#resolved_identifiers" do
      it "should return a Hash" do
        expect(solution_space.resolved_identifiers).to be_a(Hash)
      end

      it "should return all identifiers that are resolved" do
        expect(solution_space.resolved_identifiers).to be_empty

        solution_space[identifiers[0]].must_be!(1)
        expect(solution_space.resolved_identifiers).to match({identifiers[0] => 1})
      end

      it "should not include identifiers that have value" do
        identifiers[0].set!(1)
        solution_space = SolutionSpace.new(puzzle)
        solution_space[identifiers[1]].must_be!(2)

        expect(solution_space.resolved_identifiers).to match({identifiers[1] => 2})
      end
    end

    describe "#unresolved_identifiers" do
      it "should return a Hash" do
        expect(solution_space.unresolved_identifiers).to be_a(Hash)
      end

      it "should return all unresolved identifiers and their possible values" do
        expect(solution_space.unresolved_identifiers).to match(solution_space.to_hash)

        solution_space[identifiers[0]].must_be!(1)

        expect(solution_space.unresolved_identifiers).to match(
          {identifiers[1] => [2,3,4,5],
           identifiers[2] => [2,3,4,5],
           identifiers[3] => [2,3,4,5],
           identifiers[4] => [2,3,4,5]})
      end
    end

    describe "#resolvable_from_constraints" do
      it "should return a Hash" do
        expect(solution_space.resolvable_from_constraints).to be_a(Hash)
      end

      it "should return the identifiers that can be resolved by constraints" do
        puzzle = TwoConstraintPuzzle.new
        solution_space = SolutionSpace.new(puzzle)
        solution_space[puzzle.identifiers[0]].cannot_be!(1)
        solution_space[puzzle.identifiers[1]].cannot_be!(1)

        solution_space[puzzle.identifiers[2]].cannot_be!(2)
        solution_space[puzzle.identifiers[3]].cannot_be!(2)

        expect(solution_space.resolvable_from_constraints).to match(
          {puzzle.identifiers[2] => 1,
           puzzle.identifiers[4] => 2})
      end
    end

    describe "#resolve!" do

      it "should return true if the solution space becomes resolved" do
        puzzle = SingleRowPuzzle.new([1,2,3])
        puzzle.identifiers[0].set!(1)
        puzzle.identifiers[1].set!(2)
        expect(solution_space.resolve!({})).to be false
      end

      it "should return false if the solution space is still not resolved" do
        solution_space = SolutionSpace.new(SingleRowPuzzle.new([1,2,3]))
        expect(solution_space.resolve!({})).to be false
      end

      it "should raise Inconsistency if a solution is impossible" do
        puzzle = SingleRowPuzzle.new([1,2,3])
        puzzle.identifiers[0].set!(1)
        puzzle.identifiers[1].set!(1)

        expect{
          SolutionSpace.new(puzzle).resolve!({})
        }.to raise_error(Inconsistency)

      end

      it "should yield solution space, identifier and value for every step" do
        sudoku =  Sudoku.scan("0040,1000,0003,0100", 2)
        illustrate sudoku.to_s, :label=>"Given the 4x4 sudoku puzzle:"

        solution_space = SolutionSpace.new(sudoku)
        initial_implications = solution_space.resolved_identifiers
        solution_space.resolve!(initial_implications){|space,id,value|

          expect(space).to eq(solution_space)
          expect(id).to be_a(Identifier)
          expect(value).to be_a(Fixnum)

          id.set!(value)
          illustrate sudoku.to_s, :label=>"Yielded #{id.inspect}."
          true
        }

        expect(solution_space.resolved?).to be true
      end
    end

    describe "#resolve_by_trial_and_error!" do
      it "should return a completely resolved solution space if possible" do
        solution_space = SolutionSpace.new(TwoConstraintPuzzle.new)

        resolved = solution_space.resolve_by_trial_and_error!
        expect(resolved).to be_a(SolutionSpace)
        expect(resolved.resolved?).to be true
      end

      it "should raise Inconsistency if no solution is possible" do
        puzzle = TwoConstraintPuzzle.new
        solution_space = SolutionSpace.new(puzzle)
        solution_space[puzzle.identifiers[0]].cannot_be!(1)
        solution_space[puzzle.identifiers[1]].cannot_be!(1)
        solution_space[puzzle.identifiers[2]].cannot_be!(1)

        expect{
          solution_space.resolve_by_trial_and_error!
        }.to raise_error(Inconsistency)
      end
    end

    describe "#try_resolve_with" do
      it "should return SolutionSpace resolved with the the identifier and value" do
        puzzle = TwoConstraintPuzzle.new
        solution_space = SolutionSpace.new(puzzle)

        resolved = solution_space.try_resolve_with(puzzle.identifiers[0], 3)
        expect(resolved.resolved?).to be true
        expect(resolved[puzzle.identifiers[0]]).to match([3])
      end

      it "should return nil if the identifier and value makes it irresolvable." do
        puzzle = TwoConstraintPuzzle.new
        puzzle.identifiers[0].set!(1)
        puzzle.identifiers[1].set!(2)
        solution_space = SolutionSpace.new(puzzle)

        expect(solution_space.try_resolve_with(puzzle.identifiers[3], 3)).to be_nil
      end
    end

    describe "#resolved?" do
      it "should return true if the puzzle is completely resolved, false otherwise" do
        puzzle = SingleRowPuzzle.new([1,2,3])
        puzzle.identifiers[0].set!(1)
        solution_space = SolutionSpace.new(puzzle)
        expect(solution_space.resolved?).to be false

        solution_space[puzzle.identifiers[1]].must_be!(2)

        expect(solution_space.resolved?).to be true
      end
    end
  end

end

