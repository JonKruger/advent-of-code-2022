def visible?(grid, row_index, col_index)
  tree = grid[row_index][col_index]
  left_trees = grid[row_index][0...col_index]
  right_trees = grid[row_index][(col_index + 1)..]
  above_trees = grid[0...row_index].map { |row| row[col_index] }
  below_trees = grid[(row_index + 1)..].map { |row| row[col_index] }

  left_trees.all? { |other| other < tree } ||
    right_trees.all? { |other| other < tree } ||
    above_trees.all? { |other| other < tree } ||
    below_trees.all? { |other| other < tree }
end

def scenic_score(grid, row_index, col_index)
  tree = grid[row_index][col_index]
  left_trees = grid[row_index][0...col_index]
  right_trees = grid[row_index][(col_index + 1)..]
  above_trees = grid[0...row_index].map { |row| row[col_index] }
  below_trees = grid[(row_index + 1)..].map { |row| row[col_index] }

  take_until(left_trees.reverse, tree) *
    take_until(right_trees, tree) *
    take_until(above_trees.reverse, tree) *
    take_until(below_trees, tree)
end

def take_until(array, value)
  result = []
  while next_value = array.shift
    result << next_value
    break if next_value >= value
  end
  result.size
end

def part1(input)
  grid = input.split("\n").compact.map { |line| line.split("").compact.map(&:to_i) }

  grid.each_with_index.map do |row, row_index|
    row.each_with_index.map do |_, col_index|
      visible?(grid, row_index, col_index) ? 1 : 0
    end.sum
  end.sum
end

def part2(input)
  grid = input.split("\n").compact.map { |line| line.split("").compact.map(&:to_i) }

  grid.each_with_index.map do |row, row_index|
    row.each_with_index.map do |_, col_index|
      scenic_score(grid, row_index, col_index)
    end.max
  end.max
end

test_input = "1"
result = part1(test_input)
raise result.inspect unless result == 1

test_input = <<-INPUT
12
34
INPUT
result = part1(test_input)
raise result.inspect unless result == 4

test_input = <<-INPUT
30373
25512
65332
33549
35390
INPUT
result = part1(test_input)
raise result.inspect unless result == 21

result = part2(test_input)
raise result.inspect unless result == 8

input = File.read("input.txt")
puts "part1 = #{part1(input)}"
puts "part2 = #{part2(input)}"
