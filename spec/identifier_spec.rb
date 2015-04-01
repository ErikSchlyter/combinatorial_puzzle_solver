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

    describe "#set" do
      before {
        expect(identifier.value).to be_nil
        identifier.set(1)
      }

      it "should set the given value" do
        expect(identifier.value).to eq(1)
      end

      it "should fail if a value is already set" do
        expect{ identifier.set(1) }.to raise_error
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
        expect(puzzle.identifiers[1].set(2)).to be_empty
        expect(puzzle.identifiers[2].set(3)).to be_empty
        expect(puzzle.identifiers[3].set(4)).to match_array([puzzle.identifiers[4]])
      end
    end

    describe "#dependent_identifiers" do
      it "should give all other identifiers covered by its constraints" do
        puzzle = TwoConstraintPuzzle.new
        ids = puzzle.identifiers

        dependencies = {
          # ids         0       1       2       3       4       5
          # cons. 0    ###     ###     ###     ###
          # cons. 1                    ###     ###     ###     ###
          ids[0] => [         ids[1], ids[2], ids[3]                 ],
          ids[1] => [ ids[0],         ids[2], ids[3]                 ],
          ids[2] => [ ids[0], ids[1],         ids[3], ids[4], ids[5] ],
          ids[3] => [ ids[0], ids[1], ids[2],         ids[4], ids[5] ],
          ids[4] => [                 ids[2], ids[3],         ids[5] ],
          ids[5] => [                 ids[2], ids[3], ids[4]         ]
        }

        dependencies.each{|id, deps|
          expect(id.dependent_identifiers).to match_array(deps)
        }
      end
    end

    describe "#cannot_set!" do
      it "should remove the value from its set of possible values" do
        identifier.cannot_set!(3)
        expect(identifier.possible_values).to match_array([1, 2, 4, 5])
      end

      it "should return true if the identifier becomes resolvable" do
        expect(identifier.cannot_set!(1)).to be false
        expect(identifier.cannot_set!(2)).to be false
        expect(identifier.cannot_set!(3)).to be false
        expect(identifier.cannot_set!(4)).to be true
      end
    end

  end
end
