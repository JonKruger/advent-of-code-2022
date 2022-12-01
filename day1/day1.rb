def part1(input)
  input.split("\n").join(",").split(",,").map { |a| a.split(",") }.map { |a| a.map(&:to_i) }.map(&:sum).max
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


input = File.read("input.txt")
puts part1(input)