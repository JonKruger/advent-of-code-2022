def priority(letter)
  if /[a-z]/.match(letter)
    letter.ord - 96
  elsif /[A-Z]/.match(letter)
    letter.ord - 38
  end
end

def part1(input)
  lines = input.split("\n")
  lines.map do |line|
    first = line[0...(line.size / 2)].split("")
    second = line[(line.size / 2)..].split("")
    matches = first.intersection(second)
    matches.map { |letter| priority(letter) }.sum
  end.sum
end

def part2(input)
  lines = input.split("\n")
  line_groups = []
  line_groups << 3.times.collect { lines.shift.split("") } while (lines.size > 0)
  line_groups.map do |lines|
    matches = lines[0].intersection(lines[1]).intersection(lines[2])
    matches.map { |letter| priority(letter) }.sum
  end.sum
end

result = priority("a")
raise result.inspect unless result == 1

result = priority("Z")
raise result.inspect unless result == 52

test_input = <<-INPUT
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
INPUT
result = part1(test_input)
raise result.inspect unless result == 157

result = part2(test_input)
raise result.inspect unless result == 70

input = File.read("input.txt")
puts "part1 = #{part1(input)}"
puts "part2 = #{part2(input)}"
