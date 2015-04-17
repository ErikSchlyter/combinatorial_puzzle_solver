require 'rspec/illustrate'
require 'combinatorial_puzzle_solver'


module CombinatorialPuzzleSolver
  describe Possibilities do
    let(:symbols) { (1..5).to_a }
    let!(:puzzle) { SingleRowPuzzle.new(symbols) }
    let!(:solution_space) { SolutionSpace.new(puzzle) }
    let!(:identifiers) { puzzle.identifiers }

    it "is an array" do
      possibilities = solution_space[identifiers.first]
      expect(possibilities).to be_a(Array)
    end

    describe "#must_be!" do
      it "should remove all values except the given value" do
        possibilities = solution_space[identifiers.first]
        possibilities.must_be!(1)

        expect(possibilities).to match_array([1])
      end

      it "should return the dependent identifiers that becomes resolved." do
        expect(solution_space[puzzle.identifiers[0]].must_be!(1)).to match({})
        expect(solution_space[puzzle.identifiers[1]].must_be!(2)).to match({})
        expect(solution_space[puzzle.identifiers[2]].must_be!(3)).to match({})

        illustrate solution_space.inspect, :label=>"Given the solution space:"

        target_id = puzzle.identifiers[3]
        target_value = 4
        resolved = solution_space[target_id].must_be!(target_value)
        illustrate resolved.inspect,
          :label=>"It resolves the follwing if #{target_id} must be #{target_value}:"

        expect(resolved).to match(
          {puzzle.identifiers[4] => 5}
        )
      end

      it "should raise Inconsistency if identifier already has different value" do
        identifiers[0].set!(1)

        expect {
          solution_space[identifiers[0]].must_be!(2)
        }.to raise_error(Inconsistency)
      end

      it "should raise Inconsistency if the given value is not part of the set" do
        solution_space[identifiers[0]].cannot_be!(1)

        expect {
          solution_space[identifiers[0]].must_be!(1)
        }.to raise_error(Inconsistency)
      end
    end

    describe "#cannot_be!" do
      it "should remove the given value" do
        expect(solution_space[identifiers[0]]).to match([1,2,3,4,5])

        solution_space[identifiers[0]].cannot_be!(4)

        expect(solution_space[identifiers[0]]).to match([1,2,3,5])
      end

      it "should raise Inconsistency if it becomes empty" do
        solution_space[identifiers[0]].cannot_be!(1)
        solution_space[identifiers[0]].cannot_be!(2)
        solution_space[identifiers[0]].cannot_be!(3)
        solution_space[identifiers[0]].cannot_be!(4)

        expect {
          solution_space[identifiers[0]].cannot_be!(5)
        }.to raise_error(Inconsistency)
      end

      it "should raise Inconsistency if the identifier is set to the given value" do
        puzzle.identifiers[0].set!(1)

        expect {
          solution_space[identifiers[0]].cannot_be!(1)
        }.to raise_error(Inconsistency)
      end

      it "should return a Hash" do
        expect(solution_space[identifiers[0]].cannot_be!(1)).to be_a(Hash)
      end

      it "should return the same Hash object as the given one (if it is given)" do
        hash = Hash.new
        object_id = hash.object_id

        result = solution_space[identifiers[0]].cannot_be!(1, hash)

        expect(result.object_id).to eq(object_id)
      end

      it "should return the resolved identifier if it only has one remaining value" do
        solution_space[identifiers[0]].cannot_be!(1)
        solution_space[identifiers[0]].cannot_be!(2)
        solution_space[identifiers[0]].cannot_be!(3)
        expect(solution_space[identifiers[0]].cannot_be!(4)).to match(
          {identifiers[0] => 5})
      end
    end

    describe "#dependent_identifiers_cannot_be!" do
      it "should reduce possibilities of dependent identifiers" do
        solution_space[identifiers[0]].dependent_identifiers_cannot_be!(1)

        expect(solution_space[identifiers[0]]).to match([1,2,3,4,5])
        expect(solution_space[identifiers[1]]).to match([2,3,4,5])
        expect(solution_space[identifiers[2]]).to match([2,3,4,5])
        expect(solution_space[identifiers[3]]).to match([2,3,4,5])
        expect(solution_space[identifiers[4]]).to match([2,3,4,5])
      end
    end

    describe "#resolved?" do
      it "should return true if it only has one possible value, false otherwise" do
        expect(solution_space[identifiers[0]].resolved?).to be false
        solution_space[identifiers[0]].cannot_be!(1)
        solution_space[identifiers[0]].cannot_be!(2)
        solution_space[identifiers[0]].cannot_be!(3)
        solution_space[identifiers[0]].cannot_be!(4)
        expect(solution_space[identifiers[0]].resolved?).to be true
      end
    end

  end
end
