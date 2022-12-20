class Grid
  attr_reader :sand_points

  def self.parse(input)
    lines = input.split("\n")
    points = []
    points += lines.reduce([]) do |result, line|
      coordinates = line.split(" -> ")
                        .map { |pair| pair.split(",").map(&:to_i) }

      (0...(coordinates.size - 1)).each do |i|
        result += to_points_array(coordinates[i], coordinates[i + 1])
      end

      result
    end.uniq

    Grid.new(points)
  end

  def self.to_points_array(a, b)
    if a[0] == b[0]
      y_values = [a[1], b[1]].sort
      (y_values[0]..y_values[1]).map { |y| [a[0], y] }
    elsif a[1] == b[1]
      x_values = [a[0], b[0]].sort
      (x_values[0]..x_values[1]).map { |x| [x, a[1]] }
    else
      raise "not expected"
    end
  end

  def initialize(rock_points)
    @rock_points = rock_points
    @sand_points = []
    @into_the_abyss = false
    @floor_y = rock_points.map { |x, y| y }.max + 2
    @full = false
  end

  def points
    @rock_points + @sand_points
  end

  def drop_until_the_abyss
    while (!@into_the_abyss && !@full)
      drop_sand(:abyss)
      print if @sand_points.size % 100 == 0
    end
  end

  def drop_on_the_floor
    while (!@full)
      drop_sand(:floor)
      print if @sand_points.size % 100 == 0
    end
  end
  def drop_sand(mode)
    puts "dropping sand # #{@sand_points.size} #{mode}"

    current_location = [500, 0]
    previous_location = nil
    while (current_location != previous_location)
      previous_location = current_location
      current_location = process_sand_fall(current_location)

      # are we falling into the abyss?
      if current_location[1] > points.map { |_, y| y }.max
        @into_the_abyss = true
        return if mode == :abyss
      end

      # have we hit the floor?
      break if (current_location[1] == @floor_y - 1 && mode == :floor)
    end

    if current_location == [500, 0]
      @full = true
    end

    @sand_points << current_location
    nil
  end

  def process_sand_fall(current_location)
    # Sand keeps moving as long as it is able to do so, at each step trying to move down, then down-left,
    # then down-right. If all three possible destinations are blocked, the unit of sand comes to rest and
    # no longer moves

    # try to move down
    down_location = [current_location[0], current_location[1] + 1]
    return down_location if !points.include?(down_location)

    # try to move down-left
    down_left_location = [current_location[0] - 1, current_location[1] + 1]
    return down_left_location if !points.include?(down_left_location)

    # try to move down-right-
    down_right_location = [current_location[0] + 1, current_location[1] + 1]
    return down_right_location if !points.include?(down_right_location)

    current_location
  end

  def print
    x_min = points.map { |p| p[0] }.min
    x_max = points.map { |p| p[0] }.max
    y_min = points.map { |p| p[1] }.min
    y_max = points.map { |p| p[1] }.max

    output = (y_min..y_max).map do |y|
      (x_min..x_max).map do |x|
        if @rock_points.include?([x, y])
          "#"
        elsif @sand_points.include?([x, y])
          "o"
        else
          "."
        end
      end.join
    end.join("\n")

    puts((x_min..x_max).map { |_| "-"}.join + " start")
    puts output
    puts((x_min..x_max).map { |_| "-"}.join + " end")
  end

  def populated
    points.size
  end
end

test_input = <<-INPUT
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
INPUT
grid = Grid.parse(test_input)
raise grid.populated.inspect unless grid.populated == 20

grid.drop_sand(:abyss)
raise grid.populated.inspect unless grid.populated == 21

grid.drop_until_the_abyss
grid.print
raise grid.sand_points.size.inspect unless grid.sand_points.size == 24

grid.drop_on_the_floor
grid.print
raise grid.sand_points.size.inspect unless grid.sand_points.size == 93

input = File.read("input.txt")
# grid = Grid.parse(input)
# grid.drop_until_the_abyss
# puts "part1 - #{grid.sand_points.size}"

grid = Grid.parse(input)
grid.drop_on_the_floor
puts "part2 - #{grid.sand_points.size}"
