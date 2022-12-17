
class Square
  START_VALUE = -1000000
  END_VALUE = 1000000

  attr_reader :char, :value, :neighbors
  attr_accessor :distance_to_end, :location

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

  def distance_to_end=(value)
    raise unless value.is_a?(Integer)
    @distance_to_end = value
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

  def calculate_distance_to_end
    end_square.distance_to_end = 0
    processed_squares = [end_square]
    while processed_squares.size < squares.size
      processed_squares = processed_squares.map do |square|
        square.neighbors.each do |n|
          n.distance_to_end = n.distance_to_end.nil? ? square.distance_to_end + 1 : [n.distance_to_end, square.distance_to_end + 1].min
        end
        [square] + square.neighbors
      end.flatten.uniq
    end
    print_grid(:distance_to_end)
  end

  def print_grid(mode)
    row_count = squares.map { |s| s.location[0] }.max
    column_count = squares.map { |s| s.location[1] }.max

    output = (0..row_count).map do |row_index|
      (0..column_count).map do |column_index|
        square = squares.select { |s| s.location == [row_index, column_index] }.first
        case mode
        when :distance_to_end
          (square.distance_to_end&.to_s || " ").rjust(4, " ")
          # "-"
        else
          "?"
        end
      end.join + "\n"
    end.join
    puts output
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
      square.location = [row, col]
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
  grid.calculate_distance_to_end
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

# input = File.read("input.txt")
# puts("part1 = #{part1(input)}")
