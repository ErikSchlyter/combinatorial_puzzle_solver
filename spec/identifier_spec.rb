require 'rspec/illustrate'
require 'combinatorial_puzzle_solver'


module CombinatorialPuzzleSolver

  describe Identifier do
    let!(:values) { (1..5).to_a }
    let!(:puzzle) { SingleRowPuzzle.new(values) }
    let!(:identifier) { puzzle.identifiers.first }
    let!(:constraint) { puzzle.constraints.first }

    describe "#value" do
      it "should have value nil by default" do
        puzzle.identifiers.each{|identifier|
          expect(identifier.value).to be_nil
        }
      end
    end

    describe "#dependencies" do
      it "should return an Array of all dependent constraints" do
        puzzle.identifiers.each{|identifier|
          expect(identifier.dependencies).to match_array([constraint])
        }
      end
    end

    describe "#possible_values" do
      it "should match all the possible values of the puzzle" do
        expect(identifier.possible_values).to match_array(values)
      end
    end

    describe "#set!" do
      before {
        expect(identifier.value).to be_nil
        identifier.set!(1)
      }

      it "should set the given value" do
        expect(identifier.value).to eq(1)
      end

      it "should fail if a value is already set" do
        expect{ identifier.set!(1) }.to raise_error
      end

      it "should clear all possible values" do
        expect(identifier.possible_values).to be_empty
      end

      it "should notify all dependent identifiers that they can't set same value" do
        (puzzle.identifiers - [identifier]).each{|other_identifier|
          expect(other_identifier.possible_values).to match_array([2, 3, 4, 5])
        }
      end

      it "should return an array of the identifiers that becomes resolvable" do
        expect(puzzle.identifiers[1].set!(2)).to be_empty
        expect(puzzle.identifiers[2].set!(3)).to be_empty
        expect(puzzle.identifiers[3].set!(4)).to match_array([puzzle.identifiers[4]])
      end
    end

    describe "#dependent_identifiers" do
      it "should give all other identifiers covered by its constraints" do
        puzzle = TwoConstraintPuzzle.new
        ids = puzzle.identifiers

        dependencies = {
          # ids         0       1       2       3       4
          # cons. 0    ###     ###     ###
          # cons. 1                    ###     ###     ###
          ids[0] => [         ids[1], ids[2]                 ],
          ids[1] => [ ids[0],         ids[2]                 ],
          ids[2] => [ ids[0], ids[1],         ids[3], ids[4] ],
          ids[3] => [                 ids[2],         ids[4],],
          ids[4] => [                 ids[2], ids[3],        ]
        }

        dependencies.each{|id, deps|
          expect(id.dependent_identifiers).to match_array(deps)
        }
      end
    end

    describe "#cannot_be!" do
      it "should remove the value from its set of possible values" do
        identifier.cannot_be!(3)
        expect(identifier.possible_values).to match_array([1, 2, 4, 5])
      end

      it "should an array of the identifiers that becomes resolvable" do
        expect(identifier.cannot_be!(1)).to be_empty
        expect(identifier.cannot_be!(2)).to be_empty
        expect(identifier.cannot_be!(3)).to be_empty
        expect(identifier.cannot_be!(4)).to match_array([identifier])
        expect(identifier.cannot_be!(4)).to be_empty # already resolvable
      end

      it "should raise inconsistency error if it already has the given value" do
        identifier.set!(1)
        expect{ identifier.cannot_be!(1) }.to raise_error(Inconsistency)
      end

      it "should raise inconsistency error if there's no possible solutions" do
        identifier.cannot_be!(1)
        identifier.cannot_be!(2)
        identifier.cannot_be!(3)
        identifier.cannot_be!(4)
        expect{ identifier.cannot_be!(5) }.to raise_error(Inconsistency)
      end
    end

    describe "#must_be" do
      it "should remove all values except given from set of possible values" do
        identifier.must_be!(3)
        expect(identifier.possible_values).to match_array([3])
      end

      it "should remove that value from dependent identifiers' possibilities" do
        identifier.must_be!(3)
        (1..4).each{|i|
          expect(puzzle.identifiers[i].possible_values).to match_array([1,2,4,5])
        }
      end

      it "should return an array of identifiers that becomes resolvable" do
        identifiers = puzzle.identifiers
        expect(identifiers[4].must_be!(5)).to match_array([identifiers[4]])
        expect(identifiers[3].must_be!(4)).to match_array([identifiers[3]])
        expect(identifiers[2].must_be!(3)).to match_array([identifiers[2]])
        expect(identifiers[1].must_be!(2)).to match_array(identifiers[0..1])
      end
    end

    describe "#resolved?" do
      it "should return true if identifier has a unique possible value." do
        identifier.cannot_be!(5)
        identifier.cannot_be!(4)
        identifier.cannot_be!(3)
        identifier.cannot_be!(2)
        expect(identifier.resolved?).to be true
      end

      it "should return true if identifier has a value" do
        identifier.set!(1)
        expect(identifier.resolved?).to be true
      end
    end

    describe "#push_state" do
      it "should push value and possible values to a given stack" do
        stack = []

        identifier.push_state(stack)
        expect(stack[0]).to eq(nil)
        expect(stack[1]).to match_array([1,2,3,4,5])

        identifier.set!(2)

        identifier.push_state(stack)
        expect(stack[2]).to eq(2)
        expect(stack[3]).to match_array([])
      end
    end

    describe "#pop_state" do
      it "should pop the stack and set value and possible values" do
        stack = []
        identifier.push_state(stack)
        identifier.set!(2)
        identifier.pop_state(stack)

        expect(identifier.value).to eq(nil)
        expect(identifier.possible_values).to match_array([1,2,3,4,5])
      end
    end
  end
end
