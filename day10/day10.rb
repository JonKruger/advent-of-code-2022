def process(input)
  lines = input.split("\n")
  cycles = []
  current_value = 1
  while lines.any?
    line = lines.shift
    if line == "noop"
      cycles << current_value
    elsif match = /addx (\-?[0-9]+)$/.match(line)
      cycles << current_value
      current_value += match[1].to_i
      cycles << current_value
    else
      raise "not implemented - #{line}"
    end
  end
  cycles
end

def part1(input)
  cycles = process(input)
  20 * cycles[18] + 60 * cycles[58] + 100 * cycles[98] + 140 * cycles[138] + 180 * cycles[178] + 220 * cycles[218]
end

def part2(input)
  result = []
  cycles = process(input)
  cycles.each_with_index do |cycle, index|
    position = (index % 40 + 1)
    if position == 1
      result << "#"
    elsif cycle >= (position - 1) && cycle <= (position + 1)
      result << "#"
    else
      result << " "
    end
    if position == 40
      result << "\n"
    end
  end
  puts(result.join)
end

test_input = "noop"
result = process(test_input)
raise result.inspect unless result == [1]

test_input = <<-INPUT
noop
addx 3
addx -5
INPUT
result = process(test_input)
raise result.inspect unless result == [1,1,4,4,-1]

test_input = <<-INPUT
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
INPUT
result = part1(test_input)
raise result.inspect unless result == 13140

input = File.read("input.txt")
puts "part1 = #{part1(input)}"
puts "part2 = #{part2(input)}"
