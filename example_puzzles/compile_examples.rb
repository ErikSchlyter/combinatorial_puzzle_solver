#!/usr/bin/env ruby
require 'yaml'
require 'open3'

# Reads documentation and test examples from YAML (examples.yaml) files and compiles
# it into a markdown doucument.
#
# @param yaml_files [Array<String>] the yaml files to parse
# @param level [Fixnum] the initial subsection level
# @return [String] the compiled markdown document.
def compile_examples_to_markdown(yaml_files, level)
  compile(yaml_files.collect{|yaml_file| YAML.load_file(yaml_file)}, level)
end

# Compiles a given node of the YAML tree into markdown.
# - If the node is an Array, it will be compiled and concatenated.
# - If the node contains :section, it will be compiled recursively.
# - If the node contains :example, it is an example that will be executed.
# - If the node contains :comment, it is a paragraph.
#
# @param node [Object] the object that was parsed from the YAML document.
# @param level [Fixnum] the current subsection level.
# @return [String] the examples compiled into markdown.
def compile(node, level=1)
  return node.collect{|e| compile(e,level)}.join("\n") if node.is_a?(Array)

  if node.has_key?(:section) then
    "#{("#"*level)}#{node[:section]}\n" <<
    "#{node[:comment]}\n" <<
    compile(node[:content], level+1)

  elsif node.has_key?(:example)
    example_to_markdown(verify(execute(node)), level)

  elsif node.has_key?(:comment)
    "#{node[:comment]}\n"

  end
end

# @param example [Hash] the example originally described in YAML.
# @param level [Fixnum] the subsection level
# @return [String] the example formatted in markdown
def example_to_markdown(example, level)
  md = ""

  if example[:example] != "" then
    md << "#{("#"*(level))}#{example[:example]}\n\n"
  end

  if example[:comment] then
    md << example[:comment].to_s << "\n" 
  end

  example[:input_files].each{|filename|
    md << "Given the file `#{filename}`:\n"
    md << block(IO.read(filename))
  }

  if example[:input] then
    md << "Given the following input on stdin:\n"
    md << block(example[:input])
  end

  md << "Invoking `#{example[:command]}` will return exit code " <<
        "`#{example[:exit_code]}` and output:\n"
  md << block(example[:stdout])

  md
end

# @return [String] the given string formatted as a markdown code block.
def block(string)
  "\n\t#{string.gsub(/\n/,"\n\t")}\n\n"
end

# Executes an example and stores output and exit code in the hash.
#
# @param example [Hash] the example originally described in YAML.
# @return [Hash] the example
def execute(example)
  argv = example[:input_files] + example[:argv]
  example[:command] = "solve_sudoku #{argv.join(' ')}"
  full_command = "./exe/#{example[:command]}"

  Open3.popen3(full_command) {|stdin, stdout, stderr, wait_thr|
    stdin.write(example[:input]) if example[:input]

    example[:exit_code] = wait_thr.value.to_i
    example[:stdout] = stdout.read
    example[:stderr] = stderr.read
  }
  example
end

# Compares exit code and expected output to assert example executes correctly.
#
# @param example [Hash] the example to verify
# @return [Hash] the verified example
def verify(example)
  if example[:expected_output] then
    if example[:expected_output].strip != example[:stdout].strip then
      $stderr.puts "Expected:----\n#{example[:expected_output]}\n----"
      $stderr.puts "Stdout:------\n#{example[:stdout]}\n----"
      puts example.to_yaml
      fail "expected output did not match."
    end
  end

  if example[:expected_exit_code] then
    if example[:expected_exit_code] != example[:exit_code] then
      $stderr.puts example.to_yaml
      fail "Wrong exit code"
    end
  end
  example
end
