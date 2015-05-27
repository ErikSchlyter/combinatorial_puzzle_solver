require 'combinatorial_puzzle_solver'
require 'spec_helper'


module CombinatorialPuzzleSolver

  describe Puzzle do

    let!(:symbols) { (1..5).to_a }
    let!(:puzzle) { SingleRowPuzzle.new(symbols) }

    describe "#initialize" do

      it "should fail unless the block returns Constraint(s)" do
        expect { Puzzle.new(5, symbols) { "fubar" } }.to raise_error
        expect { Puzzle.new(5, symbols) { [] } }.to raise_error
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

    describe "#symbols" do
      it "should return an array of all the possible symbolsfor an identifier" do
        expect(puzzle.symbols).to be_an(Array)
        expect(puzzle.symbols).to match_array(symbols)
      end
    end

    describe "#resolve!" do
      let!(:puzzle) { puzzle = TwoConstraintPuzzle.new }

      it "should return true when puzzle is solvable" do
        illustrate puzzle.to_s
        expect(puzzle.resolve!).to be true
      end

      it "should raise inconsistency when the puzzle is unsolvable" do
        puzzle.identifiers[0].set!(1)
        puzzle.identifiers[1].set!(2)
        puzzle.identifiers[4].set!(3)

        expect{
          puzzle.resolve!
        }.to raise_error(Inconsistency)
      end

      context "when :parsed_stream is given" do
        it "should write the parsed input puzzle" do
          output = {:parsed_stream => StringIO.new}
          puzzle.resolve!(true, 0, output)

          output[:parsed_stream].rewind
          expect(output[:parsed_stream].read).to eq(
            "{  [ }  ]\n\n")
        end
      end

      context "when :steps_stream is given" do
        it "should write each resolution step" do
          puzzle.identifiers[0].set!(1)
          puzzle.identifiers[1].set!(2)
          puzzle.identifiers[4].set!(2)

          output = {:steps_stream => StringIO.new}
          puzzle.resolve!(true, 0, output)

          output[:steps_stream].rewind

          expect(output[:steps_stream].read).to eq("[2]=3\n[3]=1\n")
        end
      end

      context "when :puzzle_stream is given" do
        it "should write the puzzle for each resolution step" do
          puzzle.identifiers[0].set!(1)
          puzzle.identifiers[1].set!(2)
          puzzle.identifiers[4].set!(2)

          output = {:puzzle_stream => StringIO.new}
          puzzle.resolve!(true, 0, output)

          output[:puzzle_stream].rewind
          expect(output[:puzzle_stream].read).to eq("{12[3} 2]\n\n{12[3}12]\n\n")
        end
      end

      context "when :result_stream is given" do
        it "should write the resulting puzzle" do
          output = {:result_stream => StringIO.new}
          puzzle.resolve!(true, 0, output)

          output[:result_stream].rewind
          expect(output[:result_stream].read).to eq(
            "{12[3}12]\n\n")
        end
      end
    end
  end
end

