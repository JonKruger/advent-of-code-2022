class Grid
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
    @into_the_abyss = false
    @floor_y = rock_points.map { |x, y| y }.max + 2
    @full = false

    @max_y = -1
    @points_hash = {}
    rock_points.each do |x,y|
      add_point(x, y, :rock)
    end
  end

  def add_point(x, y, type)
    @points_hash[x] ||= {}
    @points_hash[x][y] = type
    @max_y = [@max_y, y].max
  end

  def item_at_point(location)
    @points_hash[location[0]]&.[](location[1])
  end

  def populated?(location)
    !item_at_point(location).nil?
  end

  def drop_until_the_abyss
    while (!@into_the_abyss && !@full)
      drop_sand(:abyss)
      print if populated_count % 100 == 0
    end
  end

  def drop_on_the_floor
    while (!@full)
      drop_sand(:floor)
      print if populated_count % 100 == 0
    end
  end
  def drop_sand(mode)
    puts "dropping sand # #{populated_count} #{mode}"

    current_location = [500, 0]
    previous_location = nil
    while (current_location != previous_location)
      previous_location = current_location
      current_location = process_sand_fall(current_location)

      # are we falling into the abyss?
      if current_location[1] > @max_y
        @into_the_abyss = true
        return if mode == :abyss
      end

      # have we hit the floor?
      break if (current_location[1] == @floor_y - 1 && mode == :floor)
    end

    if current_location == [500, 0]
      @full = true
    end

    add_point(*current_location, :sand)
    nil
  end

  def process_sand_fall(current_location)
    # Sand keeps moving as long as it is able to do so, at each step trying to move down, then down-left,
    # then down-right. If all three possible destinations are blocked, the unit of sand comes to rest and
    # no longer moves

    # try to move down
    down_location = [current_location[0], current_location[1] + 1]
    return down_location unless populated?(down_location)

    # try to move down-left
    down_left_location = [current_location[0] - 1, current_location[1] + 1]
    return down_left_location unless populated?(down_left_location)

    # try to move down-right-
    down_right_location = [current_location[0] + 1, current_location[1] + 1]
    return down_right_location unless populated?(down_right_location)

    current_location
  end

  def print
    x_min = @points_hash.keys.min
    x_max = @points_hash.keys.max
    y_min = @points_hash.values.map { |y_hash| y_hash.keys }.flatten.min
    y_max = @points_hash.values.map { |y_hash| y_hash.keys }.flatten.max

    output = (y_min..y_max).map do |y|
      (x_min..x_max).map do |x|
        item = item_at_point([x, y])
        if item == :rock
          "#"
        elsif item == :sand
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

  def populated_count
    @points_hash.map { |x, y_hash| y_hash.size }.sum
  end

  def sand_count
    @points_hash.values.map { |y_hash| y_hash.values.select { |v| v == :sand }.size }.flatten.sum
  end
end

test_input = <<-INPUT
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
INPUT
grid = Grid.parse(test_input)
raise grid.populated_count.inspect unless grid.populated_count == 20

grid.drop_sand(:abyss)
raise grid.populated_count.inspect unless grid.populated_count == 21

grid.drop_until_the_abyss
grid.print
raise grid.sand_count.inspect unless grid.sand_count == 24

grid.drop_on_the_floor
grid.print
raise grid.sand_count.inspect unless grid.sand_count == 93

input = File.read("input.txt")
grid = Grid.parse(input)
grid.drop_until_the_abyss
grid.print
puts "part1 - #{grid.sand_count}"

grid = Grid.parse(input)
grid.drop_on_the_floor
grid.print
puts "part2 - #{grid.sand_count}"
