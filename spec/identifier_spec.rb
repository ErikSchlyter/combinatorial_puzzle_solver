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

    describe "#has_value?" do
      it "should return true if it has a value, false otherwise" do
        expect(identifier.has_value?).to be false

        identifier.set!(1)
        expect(identifier.has_value?).to be true

        identifier.set!(nil)
        expect(identifier.has_value?).to be false
      end
    end

    describe "#constraints" do
      it "should return an Array of all dependent constraints" do
        puzzle.identifiers.each{|identifier|
          expect(identifier.constraints).to match_array([constraint])
        }
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
  end
end
