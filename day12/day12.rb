
class Square
  START_VALUE = -1000000
  END_VALUE = 1000000

  attr_reader :char, :value, :neighbors

  def initialize(char)
    @char = char
    @value = Square.square_value(char)
    @neighbors = []
  end

  def self.square_value(char)
    if char == "S"
      1
    elsif char == "E"
      26
    else
      char.ord - 96
    end
  end

  def steppable_neighbors
    @steppable_neighbors ||= (neighbors.select { |n| n.value <= value + 1 })
  end

  def start?
    char == "S"
  end

  def end?
    char == "E"
  end
end


class Grid
  attr_reader :squares

  def initialize(squares)
    @squares = squares.freeze
  end

  def start_square
    squares.select(&:start?).first
  end

  def end_square
    squares.select(&:end?).first
  end
end

class Sequence
  attr_reader :squares

  def initialize(squares)
    @squares = squares.freeze
  end

  def step
    steppable_neighbors.map do |n|
      Sequence.new(squares + [n])
    end
  end

  def steppable_neighbors
    @squares.last.steppable_neighbors - @squares
  end

  def complete?
    @squares.last.end?
  end

  def size
    @squares.size
  end
end

def build_grid(input)
  rows = input.split("\n").compact.map { |row| row.chars.compact.map { |value| Square.new(value) } }
  num_rows = rows.size
  num_cols = input.split("\n").compact[0].length

  (0...num_rows).each do |row|
    (0...num_cols).each do |col|
      square = rows[row][col]
      square.neighbors << rows[row][col-1] if col > 0
      square.neighbors << rows[row][col+1] if col < num_cols - 1
      square.neighbors << rows[row-1][col] if row > 0
      square.neighbors << rows[row+1][col] if row < num_rows - 1
    end
  end
  all_squares = rows.flatten

  raise if all_squares.any? { |node| node.value.nil? }
  raise if all_squares.any? { |node| node.neighbors.length < 2 }

  Grid.new(all_squares)
end

def part1(input)
  grid = build_grid(input)
  sequences = [Sequence.new([grid.start_square])]
  steps = 0
  while !sequences.any?(&:complete?)
    sequences = sequences.map { |s| s.step }.flatten
    steps += 1
    puts "After #{steps} steps, I have #{sequences.size} sequences"
  end
  puts sequences.select(&:complete?).first.squares.map(&:char).inspect
  steps
end

test_input = <<-INPUT
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
INPUT

result = part1(test_input)
raise result.inspect unless result == 31