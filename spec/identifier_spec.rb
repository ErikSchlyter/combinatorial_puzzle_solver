require 'rspec/illustrate'
require 'combinatorial_puzzle_solver'


module CombinatorialPuzzleSolver

  describe Identifier do
    let!(:values) { (1..5).to_a }
    let!(:puzzle) { SingleRowPuzzle.new(values) }

    describe "#value" do
      it "should have value nil by default" do
        puzzle.identifiers.each{|identifier|
          expect(identifier.value).to be_nil
        }
      end
    end

    describe "#dependencies" do
      it "should return an Array of all dependent constraints" do
        identifiers = puzzle.identifiers
        constraint = puzzle.constraints.first

        identifiers.each{|identifier|
          expect(identifier.dependencies).to match_array([constraint])
        }
      end
    end

    describe "#possible_values" do
      it "should match all the possible values of the puzzle" do
        identifier = puzzle.identifiers.first

        expect(identifier.possible_values).to match_array(values)
      end

      #it "should not contain any values already set (wihtin the same constraints)" do
      #end
    end

    describe "#set" do
      let!(:identifier) { puzzle.identifiers.first }
      before {
        expect(identifier.value).to be_nil
        identifier.set(3)
      }

      it "should set the given value" do
        expect(identifier.value).to eq(3)
      end

      it "should fail if a value is already set" do
        expect{ identifier.set(3) }.to raise_error
      end

      it "should clear all possible values" do
        expect(identifier.possible_values).to be_empty
      end

      it "should notify all dependent identifiers that they can't set same value" do
        (puzzle.identifiers - [identifier]).each{|other_identifier|
          expect(other_identifier.possible_values).to match_array([1, 2, 4, 5])
        }
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
        identifier = puzzle.identifiers.first

        identifier.cannot_set!(3)
        expect(identifier.possible_values).to match_array([1, 2, 4, 5])
      end
    end

  end
end
