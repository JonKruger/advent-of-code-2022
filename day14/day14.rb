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
    @rock_points = rock_points
  end

  def points
    @rock_points
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
        else
          "."
        end
      end.join
    end.join("\n")
    puts output
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
grid.print
raise grid.populated.inspect unless grid.populated == 20
