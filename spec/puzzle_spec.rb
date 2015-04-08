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

    describe "push and pop states" do
      it "store the state on the stack and be able to retrieve it" do
        puzzle.identifiers[0].cannot_be!(2)
        puzzle.identifiers[0].cannot_be!(3)

        puzzle.push_state
        puzzle.identifiers[0].set!(1)
        puzzle.pop_state!

        expect(puzzle.identifiers[0].value).to be_nil
        expect(puzzle.identifiers[0].possible_values).to match_array([1,4,5])
      end
    end

    describe "#resolve_constraints!" do
      it "should resolve all constraints and return a Hash of resolved identifiers" do
        puzzle = TwoConstraintPuzzle.new
        puzzle.identifiers[0].cannot_be!(1)
        puzzle.identifiers[1].cannot_be!(1)
        puzzle.identifiers[3].cannot_be!(2)

        solutions = puzzle.resolve_constraints!

        expect(solutions).to match({
          puzzle.identifiers[2] => 1,
          puzzle.identifiers[3] => 3,
          puzzle.identifiers[4] => 2
        })
      end
    end

    describe "#resolve_with!" do
      let!(:puzzle) { puzzle = TwoConstraintPuzzle.new }
      before {
        puzzle.identifiers[0].set!(1)
        puzzle.identifiers[1].set!(2)
      }

      context "when puzzle becomes unsolvable" do
        let!(:bad_attempt) { puzzle.resolve_with!(puzzle.identifiers.last, 3) }

        it "should return false" do
          expect(bad_attempt).to be false
        end

        it "should not be resolved" do
          bad_attempt
          expect(puzzle.resolved?).to be false
        end

        it "should keep the current stack size" do
          size_before = puzzle.instance_variable_get(:@state_stack).size

          bad_attempt

          expect(puzzle.instance_variable_get(:@state_stack).size).to eq(size_before)
        end

        it "should yield the failed identifier and value" do
          identifier = puzzle.identifiers.last
          value = 3
          expect {|block|
            puzzle.resolve_with!(identifier, value, &block)
          }.to yield_with_args(identifier, value)

        end
      end

      context "when the puzzle is solvable" do
        let!(:good_attempt) { puzzle.resolve_with!(puzzle.identifiers.last, 1) }

        it "should return a Hash" do
          expect(good_attempt).to be_a(Hash)
        end

        it "it should solve the puzzle" do
          good_attempt
          expect(puzzle.resolved?).to be true
        end
      end
    end

    describe "#resolve" do
      let!(:puzzle) { puzzle = TwoConstraintPuzzle.new }
      context "when puzzle is solvable" do
        it "should solve the puzzle" do
          puzzle.resolve!
          expect(puzzle.resolved?).to be true
        end

        it "should return a Hash of resolved identifiers" do
          solutions = puzzle.resolve!
          expect(solutions).to be_a(Hash)
          expect(solutions.keys).to match_array(puzzle.identifiers)
          solutions.each{|identifier, value|
            expect(identifier.possible_values).to match_array([value])
          }
        end
      end

      context "when the puzzle is unsolvable" do
        before {
          puzzle.identifiers[0].set!(1)
          puzzle.identifiers[1].set!(2)
          begin
            puzzle.identifiers[4].set!(3)
          rescue Inconsistency
            # it's hard to setup a failed puzzle without triggering Inconsistency
          end
        }

        it "should return a Hash of resolved identifiers" do
          solutions = puzzle.resolve!
          expect(solutions).to be_a(Hash)
          expect(solutions).to be_empty
        end

        it "should not solve the puzzle" do
          puzzle.resolve!
          expect(puzzle.resolved?).to be false
        end
      end
    end

    describe "#unresolved_identifiers" do
      it "should return an Array of all identifiers that are unresolved" do
        puzzle = TwoConstraintPuzzle.new
        puzzle.identifiers[0].set!(1)

        expect(puzzle.unresolved_identifiers).to match_array(puzzle.identifiers[1..4])
      end
    end

  end
end

