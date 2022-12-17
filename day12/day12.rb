
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

  def end?
    char == "E"
  end

  def distance_to_end=(value)
    raise unless value.is_a?(Integer)
    @distance_to_end = value
  end
end


class Grid
  attr_reader :squares, :square_grid

  def initialize(square_grid, start_selector)
    @square_grid = square_grid
    @squares = square_grid.flatten
    @start_selector = start_selector
  end

  def start_squares
    squares.select { |s| @start_selector.call(s) }
  end

  def end_square
    @end_square ||= squares.select(&:end?).first
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
  end
end

class StupidStepper
  def step(sequence)
    sequence.steppable_neighbors.map do |n|
      Sequence.new(sequence.squares + [n])
    end
  end
end

# class LookaheadStepper
#   def step(sequence)
#
#   end
# end

class Sequence
  attr_reader :squares

  def self.stepper
    @@stepper ||= StupidStepper.new
  end
  def initialize(squares)
    @squares = squares.freeze
  end

  def step
    self.class.stepper.step(self)
  end

  def steppable_neighbors
    @steppable_neighbors ||= last.steppable_neighbors - @squares
  end

  def complete?
    last.end?
  end

  def size
    @squares.size
  end

  def last
    @squares.last
  end

  def distance_to_end
    last.distance_to_end
  end
end

def build_grid(input, start_selector)
  rows = input.split("\n").compact.map { |row| row.chars.compact.map { |value| Square.new(value) } }
  num_rows = rows.size
  num_cols = input.split("\n").compact[0].length

  square_grid = (0...num_rows).map do |row|
    (0...num_cols).map do |col|
      square = rows[row][col]
      square.location = [row, col]
      square.neighbors << rows[row][col-1] if col > 0
      square.neighbors << rows[row][col+1] if col < num_cols - 1
      square.neighbors << rows[row-1][col] if row > 0
      square.neighbors << rows[row+1][col] if row < num_rows - 1
      square
    end
  end
  all_squares = rows.flatten

  raise if all_squares.any? { |node| node.value.nil? }
  raise if all_squares.any? { |node| node.neighbors.length < 2 }

  Grid.new(square_grid, start_selector)
end

def run(input, start_selector)
  grid = build_grid(input, start_selector)
  grid.calculate_distance_to_end

  sequences = grid.start_squares.map { |start_square| Sequence.new([start_square]) }
  steps = 0
  start_time = Time.now
  puts "starting with #{sequences.size} sequences"
  while !sequences.any?(&:complete?)
    sequences = prune(sequences.map { |s| s.step }.flatten)
    steps += 1
    raise if sequences.empty?
    puts "After #{steps} steps, I have #{sequences.size} sequences (#{sequences.map { |s| s.last.value }.tally})"
  end
  puts "finished in #{Time.now - start_time} seconds"
  sequences.select(&:complete?).first.size - 1
end

def prune(sequences)
  # prune duplicate sequences
  sequences = sequences.group_by(&:last).map { |_, values| values.sort_by { |s| -s.distance_to_end }.first }

  # prune sequences where other sequences have already moved farther along
  # past_squares = sequences.map { |s| s.squares[0...-1] }.uniq
  # last_squares = sequences.map(&:last)
  # last_squares_to_keep = last_squares - past_squares
  # sequences = sequences.select { |s| last_squares_to_keep.include?(s.last) }

  # prune sequences that are farther away
  least_distance = sequences.map(&:distance_to_end).min
  sequences.select { |s| s.distance_to_end <= least_distance + 80 }

  # prune sequences with values that are too low
  highest_value = sequences.map { |s| s.last.value }.max
  sequences.select { |s| s.last.value >= highest_value - 5 }
end

test_input = <<-INPUT
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
INPUT

part1_start_selector = lambda { |square| square.char == "S" }

result = run(test_input, part1_start_selector)
raise result.inspect unless result == 31

input = File.read("input.txt")
result = run(input, part1_start_selector)
puts("part1 = #{result}")

part2_start_selector = lambda { |square| ["S", "a"].include?(square.char) }
result = run(test_input, part2_start_selector)
raise result.inspect unless result == 29

result = run(input, part2_start_selector)
puts("part2 = #{result}")
