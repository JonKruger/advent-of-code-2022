def part1(input)
  input.split("\n").join(",").split(",,").map { |a| a.split(",") }.map { |a| a.map(&:to_i) }.map(&:sum).max
end

def part2(input)
  elves = input.split("\n").join(",").split(",,").map { |a| a.split(",") }.map { |a| a.map(&:to_i) }.map(&:sum).sort.reverse[0..2].sum
end

test_input = <<-INPUT
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
INPUT
result = part1(test_input)
raise result.inspect if result != 24000

result = part2(test_input)
raise result.inspect if result != 45000

input = File.read("input.txt")
puts "part1 - #{part1(input)}"
puts "part2 - #{part2(input)}"
