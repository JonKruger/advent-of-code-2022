require "json"

def parse_list_string_pair(input)
  input.split("\n").compact.map { |line| parse_line(line) }
end

def parse_line(line)
  JSON.parse(line)
end

def in_correct_order?(lists)
  (0..(lists.map(&:size).max)).each do |i|
    # When comparing two values, the first value is called left and the second value is called right.
    left, right = lists.map do |list|
      list[i]
    end

    # If the left list runs out of items first, the inputs are in the right order.
    return true if left.nil? && !right.nil?
    # If the right list runs out of items first, the inputs are not in the right order.
    return false if !left.nil? && right.nil?
    # If the lists are the same length and no comparison makes a decision about the order, continue
    # checking the next part of the input.

    # If both values are integers, the lower integer should come first.
    if left.is_a?(Integer) && right.is_a?(Integer)
      # If the left integer is lower # than the right integer, the inputs are in the right order.
      return true if left < right
      # If the left integer is higher than the right integer, the inputs are not in the right order.
      return false if left > right
      # Otherwise, the inputs are the same integer; continue checking the next part of the input.
    end

    # If both values are lists, compare the first value of each list, then the second value, and so on.
    if left.is_a?(Array) && right.is_a?(Array)
      result = in_correct_order?([left, right])
      return result unless result.nil?
    end

    # If exactly one value is an integer, convert the integer to a list which contains that integer
    # as its only value, then retry the comparison. For example, if comparing [0,0,0] and 2, convert
    # the right value to [2] (a list containing 2); the result is then found by instead comparing
    # [0,0,0] and [2].
    if left.is_a?(Array) && right.is_a?(Integer)
      result = in_correct_order?([left, [right]])
      return result unless result.nil?
    end
    if left.is_a?(Integer) && right.is_a?(Array)
      result = in_correct_order?([[left], right])
      return result unless result.nil?
    end

  end
  return nil
end

def part1(input)
  input.split("\n\n")
               .map { |pair| parse_list_string_pair(pair) }
               .map { |lists| in_correct_order?(lists) }
               .each_with_index.reduce(0) { |output, (result, i)| output + (result ? i + 1 : 0) }
end

def part2(input)
  divider1 = [[2]]
  divider2 = [[6]]

  parsed_arrays = input.split("\n")
       .select { |line| !line.empty? }
       .map { |pair| parse_line(pair) }
  parsed_arrays << divider1
  parsed_arrays << divider2

  parsed_arrays = parsed_arrays.sort { |a, b| in_correct_order?([a, b]) ? -1 : 1 }

  (parsed_arrays.find_index(divider1) + 1) * (parsed_arrays.find_index(divider2) + 1)
end

test_input = <<-INPUT
[1,1,3,1,1]
[1,1,5,1,1]
INPUT
raise unless in_correct_order?(parse_list_string_pair(test_input))

test_input = <<-INPUT
[[1],[2,3,4]]
[[1],4]
INPUT
raise unless in_correct_order?(parse_list_string_pair(test_input))

test_input = <<-INPUT
[9]
[[8,7,6]]
INPUT
raise if in_correct_order?(parse_list_string_pair(test_input))

test_input = <<-INPUT
[[4,4],4,4]
[[4,4],4,4,4]
INPUT
raise unless in_correct_order?(parse_list_string_pair(test_input))

test_input = <<-INPUT
[7,7,7,7]
[7,7,7]
INPUT
raise if in_correct_order?(parse_list_string_pair(test_input))

test_input = <<-INPUT
[]
[3]
INPUT
raise unless in_correct_order?(parse_list_string_pair(test_input))

test_input = <<-INPUT
[[[]]]
[[]]
INPUT
raise if in_correct_order?(parse_list_string_pair(test_input))

test_input = <<-INPUT
[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
INPUT
raise if in_correct_order?(parse_list_string_pair(test_input))

test_input = <<-INPUT
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
INPUT
result = part1(test_input)
raise result.inspect unless result == 13

result = part2(test_input)
raise result.inspect unless result == 140

input = File.read("input.txt")
puts("part1 - #{part1(input)}")
puts("part2 - #{part2(input)}")
