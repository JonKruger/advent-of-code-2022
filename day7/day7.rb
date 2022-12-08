project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/lib/**/*.rb', &method(:require))

def part1(input)
  parser = Parser.new
  parser.process(input)
  return parser.file_system.total_size_at_most(100000)
end

def part2(input)
  parser = Parser.new
  parser.process(input)

  space_needed = 30_000_000 - (70_000_000 - parser.file_system.root_directory.total_size)
  all_directory_sizes = parser.file_system.all_directory_sizes
  all_directory_sizes.select { |size| size >= space_needed }.min
end


test_input = <<-INPUT
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
INPUT
result = part1(test_input)
raise result.inspect if result != 95437

result = part2(test_input)
raise result.inspect if result != 24933642

input = File.read("input.txt")
puts "part1 - #{part1(input)}"
puts "part2 - #{part2(input)}"
  