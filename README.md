# Combinatorial Puzzle Solver [![Gem Version](https://badge.fury.io/rb/combinatorial_puzzle_solver.svg)](http://badge.fury.io/rb/combinatorial_puzzle_solver)

A resolver of combinatorial number-placement puzzles, like Sudoku.

Source code at [https://github.com/ErikSchlyter/combinatorial_puzzle_solver](https://github.com/ErikSchlyter/combinatorial_puzzle_solver).

Documentation at [http://www.erisc.se/combinatorial_puzzle_solver](http://www.erisc.se/combinatorial_puzzle_solver).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'combinatorial_puzzle_solver'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install combinatorial_puzzle_solver

## Usage for `solve_sudoku`

The program `solve_sudoku` reads sudoku puzzles from files
(or stdin, if no filenames is given) and solves them by
constraint resolution. If constraint resolution is not enough
to solve the puzzle, it will resort to a trial and error
approach. The exit code will indicate if all parsed puzzles
were completely solved or not.

Each resolution step and the current state of the puzzle can
be written to stdout for diagnostic purposes. It is also
possible to abort after a given number of steps if a complete
resolution is not desired, which would be the case if you only
want a couple of clues.

Note that the step output and abort functionality is not
available when the puzzle is solved by trial and error.

The default behavior is resolve all given puzzles (with trial
and error, if neccessary) and indicate by exit status whether
all puzzles where completely resolved. No output is given
unless explicitly asked for.


###Printing the parsed puzzles, `-i`.

The parser will interpret digits (0-9) as values in the puzzle
and disregard anything else. The option `-i` will output the
parsed puzzle before it solves it.

Given the file `example_puzzles/simple`:

	906813540
	201045063
	040000000
	000620009
	009000200
	700034000
	000000090
	590360104
	027459306
	

Invoking `solve_sudoku example_puzzles/simple -i` will return exit code `0` and output:

	9   6|8 1 3|5 4  
	2   1|  4 5|  6 3
	  4  |     |     
	-----+-----+-----
	     |6 2  |    9
	    9|     |2    
	7    |  3 4|     
	-----+-----+-----
	     |     |  9  
	5 9  |3 6  |1   4
	  2 7|4 5 9|3   6
	
	


###Parsing several puzzles at the same time

Given the file `example_puzzles/simple`:

	906813540
	201045063
	040000000
	000620009
	009000200
	700034000
	000000090
	590360104
	027459306
	

Given the file `example_puzzles/medium`:

	000|301|000
	009|000|000
	080|000|030
	---+---+---
	000|004|980
	007|120|500
	200|090|170
	---+---+---
	050|012|000
	090|007|000
	300|405|008
	
	

Invoking `solve_sudoku example_puzzles/simple example_puzzles/medium -i` will return exit code `0` and output:

	9   6|8 1 3|5 4  
	2   1|  4 5|  6 3
	  4  |     |     
	-----+-----+-----
	     |6 2  |    9
	    9|     |2    
	7    |  3 4|     
	-----+-----+-----
	     |     |  9  
	5 9  |3 6  |1   4
	  2 7|4 5 9|3   6
	
	     |3   1|     
	    9|     |     
	  8  |     |  3  
	-----+-----+-----
	     |    4|9 8  
	    7|1 2  |5    
	2    |  9  |1 7  
	-----+-----+-----
	  5  |  1 2|     
	  9  |    7|     
	3    |4   5|    8
	
	


###Parsing 4x4 puzzles, `-4`, `-4x4`.

Given the file `example_puzzles/4x4`:

	this is a tiny puzzle 0040100000030100
	

Invoking `solve_sudoku example_puzzles/4x4 -i -4` will return exit code `0` and output:

	   |4  
	1  |   
	---+---
	   |  3
	  1|   
	
	


###Printing the output, `-o`.

Given the file `example_puzzles/simple`:

	906813540
	201045063
	040000000
	000620009
	009000200
	700034000
	000000090
	590360104
	027459306
	

Invoking `solve_sudoku example_puzzles/simple -o` will return exit code `0` and output:

	9 7 6|8 1 3|5 4 2
	2 8 1|7 4 5|9 6 3
	3 4 5|2 9 6|8 1 7
	-----+-----+-----
	8 5 3|6 2 1|4 7 9
	4 6 9|5 7 8|2 3 1
	7 1 2|9 3 4|6 5 8
	-----+-----+-----
	6 3 4|1 8 2|7 9 5
	5 9 8|3 6 7|1 2 4
	1 2 7|4 5 9|3 8 6
	
	


###Printing the resolution steps, `-s`.

Given the file `example_puzzles/simple`:

	906813540
	201045063
	040000000
	000620009
	009000200
	700034000
	000000090
	590360104
	027459306
	

Invoking `solve_sudoku example_puzzles/simple -o -s` will return exit code `0` and output:

	[1,2]=7
	[8,3]=8
	[9,8]=8
	[1,9]=2
	[2,2]=8
	[9,1]=1
	[7,7]=7
	[3,1]=3
	[7,5]=8
	[7,9]=5
	[2,7]=9
	[8,8]=2
	[3,3]=5
	[5,5]=7
	[2,4]=7
	[3,7]=8
	[8,6]=7
	[6,3]=2
	[3,5]=9
	[4,7]=4
	[6,7]=6
	[3,4]=2
	[4,1]=8
	[4,3]=3
	[3,6]=6
	[7,4]=1
	[4,6]=1
	[7,3]=4
	[7,6]=2
	[5,4]=5
	[4,2]=5
	[5,6]=8
	[7,1]=6
	[6,4]=9
	[4,8]=7
	[6,2]=1
	[5,9]=1
	[7,2]=3
	[5,1]=4
	[3,8]=1
	[6,8]=5
	[6,9]=8
	[5,2]=6
	[5,8]=3
	[3,9]=7
	9 7 6|8 1 3|5 4 2
	2 8 1|7 4 5|9 6 3
	3 4 5|2 9 6|8 1 7
	-----+-----+-----
	8 5 3|6 2 1|4 7 9
	4 6 9|5 7 8|2 3 1
	7 1 2|9 3 4|6 5 8
	-----+-----+-----
	6 3 4|1 8 2|7 9 5
	5 9 8|3 6 7|1 2 4
	1 2 7|4 5 9|3 8 6
	
	


###Printing the entire puzzle for each resolution step, `-p`.

Given the file `example_puzzles/4x4`:

	this is a tiny puzzle 0040100000030100
	

Invoking `solve_sudoku example_puzzles/4x4 --4x4 -p` will return exit code `0` and output:

	   |4  
	1  |  2
	---+---
	   |  3
	  1|   
	
	   |4  
	1  |  2
	---+---
	   |  3
	  1|2  
	
	   |4  
	1  |3 2
	---+---
	   |  3
	  1|2  
	
	   |4 1
	1  |3 2
	---+---
	   |  3
	  1|2  
	
	   |4 1
	1  |3 2
	---+---
	   |  3
	  1|2 4
	
	   |4 1
	1  |3 2
	---+---
	   |1 3
	  1|2 4
	
	   |4 1
	1 4|3 2
	---+---
	   |1 3
	  1|2 4
	
	   |4 1
	1 4|3 2
	---+---
	   |1 3
	3 1|2 4
	
	   |4 1
	1 4|3 2
	---+---
	  2|1 3
	3 1|2 4
	
	2  |4 1
	1 4|3 2
	---+---
	  2|1 3
	3 1|2 4
	
	2  |4 1
	1 4|3 2
	---+---
	4 2|1 3
	3 1|2 4
	
	2 3|4 1
	1 4|3 2
	---+---
	4 2|1 3
	3 1|2 4
	
	


###Use constraint resolution only, `-r`.

You can avoid the trial and error functionality. Note though that this might not
lead to a completely solved puzzle, which would imply a failure return code.

The input and incomplete result is demonstrated below.

Given the file `example_puzzles/medium`:

	000|301|000
	009|000|000
	080|000|030
	---+---+---
	000|004|980
	007|120|500
	200|090|170
	---+---+---
	050|012|000
	090|007|000
	300|405|008
	
	

Invoking `solve_sudoku example_puzzles/medium -i -o -r` will return exit code `256` and output:

	     |3   1|     
	    9|     |     
	  8  |     |  3  
	-----+-----+-----
	     |    4|9 8  
	    7|1 2  |5    
	2    |  9  |1 7  
	-----+-----+-----
	  5  |  1 2|     
	  9  |    7|     
	3    |4   5|    8
	
	  2  |3 8 1|  5 9
	  3 9|7 5 6|8 2  
	  8 5|2 4 9|  3  
	-----+-----+-----
	5 1 3|6 7 4|9 8 2
	9   7|1 2 8|5   3
	2   8|5 9 3|1 7  
	-----+-----+-----
	8 5  |9 1 2|3   7
	  9 2|8 3 7|  1 5
	3 7 1|4 6 5|2 9 8
	
	


Given the file `example_puzzles/hard`:

	000|200|063
	300|005|401
	001|003|980
	---+---+---
	000|000|090
	000|538|000
	030|000|000
	---+---+---
	026|300|500
	503|700|008
	470|001|000
	

Invoking `solve_sudoku example_puzzles/hard -i -o -r` will return exit code `256` and output:

	     |2    |  6 3
	3    |    5|4   1
	    1|    3|9 8  
	-----+-----+-----
	     |     |  9  
	     |5 3 8|     
	  3  |     |     
	-----+-----+-----
	  2 6|3    |5    
	5   3|7    |    8
	4 7  |    1|     
	
	     |2 1  |7 6 3
	3   7|    5|4 2 1
	2   1|  7 3|9 8 5
	-----+-----+-----
	     |     |3 9  
	     |5 3 8|     
	  3  |     |8 5  
	-----+-----+-----
	  2 6|3    |5    
	5   3|7    |    8
	4 7  |  5 1|  3  
	
	


###Abort after a given number of steps, `-c NUM`, `--clues NUM`.

If you don't want the entire puzzle solved, but just a couple of clues on
how to get forward, you can abort the resolution with `-c`, and print each
step with  `-s`.

Given the file `example_puzzles/simple`:

	906813540
	201045063
	040000000
	000620009
	009000200
	700034000
	000000090
	590360104
	027459306
	

Invoking `solve_sudoku example_puzzles/simple -s -c 3` will return exit code `0` and output:

	[1,2]=7
	[8,3]=8
	[9,8]=8
	



## Development

After checking out the repo, run `bin/setup` to install dependencies.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/ErikSchlyter/combinatorial_puzzle_solver/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
