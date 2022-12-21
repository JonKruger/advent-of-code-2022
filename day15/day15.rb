class Sensor
  attr_reader :location, :closest_beacon_location
  def initialize(location, closest_beacon_location)
    @location = location.freeze
    @closest_beacon_location = closest_beacon_location.freeze
  end

  def distance_to(other_location)
    (0..1).map { |i| (@location[i] - other_location[i]).abs }.sum
  end

  def distance_to_closest_beacon
    @distance_to_closest_beacon ||= distance_to(closest_beacon_location)
  end

  def no_beacon_spaces(min_coord, max_coord)
    min_y = [location[1] - distance_to_closest_beacon, min_coord].max
    max_y = [location[1] + distance_to_closest_beacon, max_coord].min
    (min_y..max_y).reduce([]) do |spaces, y|
      puts "... calculating no beacon spaces for #{y}"
      spaces += no_beacon_spaces_x(y, min_coord, max_coord).map { |x| [x, y] }
    end
  end

  def no_beacon_spaces_x(y, min_coord, max_coord)
    min_x = [location[0] - (distance_to_closest_beacon - (y - location[1]).abs), min_coord].max
    max_x = [location[0] + (distance_to_closest_beacon - (y - location[1]).abs), max_coord].min
    spaces = (min_x..max_x).to_a
    spaces -= [closest_beacon_location[0]] if closest_beacon_location[1] == y
    spaces
  end
end

class Grid
  def self.parse(input)
    lines = input.split("\n")
    sensors = lines.map do |line|
      match = /^Sensor\sat\sx=([\-0-9]+), y=([\-0-9]+): closest beacon is at x=([\-0-9]+), y=([\-0-9]+)$/.match(line)
      Sensor.new([match[1].to_i, match[2].to_i], [match[3].to_i, match[4].to_i])
    end

    Grid.new(sensors)
  end

  attr_reader :sensors

  def initialize(sensors)
    @sensors = sensors.freeze
  end

  def sensor_at(location)
    sensors.select { |s| s.location == location }.first
  end

  def no_beacon_spaces_x(y, min_coord, max_coord)
    sensors.map { |s| s.no_beacon_spaces_x(y, min_coord, max_coord) }.flatten.uniq.sort
  end

  def no_beacon_spaces
    sensors.reduce([]) do |spaces, s|
      sensor_no_beacon_spaces = s.no_beacon_spaces
      puts("sensor #{s.location.inspect} has #{sensor_no_beacon_spaces.size} no beacon spaces")
      spaces += sensor_no_beacon_spaces
    end.uniq - beacon_locations
  end

  def beacon_locations
    sensors.map { |s| s.closest_beacon_location }.uniq
  end

  def find_missing_beacon(min_coord, max_coord)
    puts("find_missing_beacon")
    # puts("#{(no_beacon_spaces + beacon_locations).size} spaces to process")
    hash = {}

    (min_coord..max_coord).each do |y|
      puts("checking #{y}")
      x_locations = (sensors.reduce([]) { |x_list, s| x_list += s.no_beacon_spaces_x(y, min_coord, max_coord) } + beacon_locations.select { |_, y_loc| y_loc == y }.map { |x_loc, _| x_loc })
                      .uniq
                      .select { |x| x >= min_coord && x <= max_coord }
      if x_locations.size != max_coord - min_coord + 1
        return [((min_coord..max_coord).to_a - x_locations)[0], y]
      end
    end

    raise "no missing beacon found"
    #
    # (no_beacon_spaces + beacon_locations).each do |x, y|
    #   if x >= min_coord && x <= max_coord && y >= min_coord && y <= max_coord
    #     hash[y] ||= {}
    #     hash[y][x] = 1
    #   end
    # end
    #
    # (min_coord..max_coord).each do |y|
    #   if hash[y].keys.size != max_coord - min_coord + 1
    #     puts("checking #{y}")
    #     x = ((min_coord..max_coord).to_a - hash[y].keys)[0]
    #     return [x, y]
    #   end
    # end
  end
end

def part1(input)
  grid = Grid.parse(input)
  grid.no_beacon_spaces_x(2000000).size
end

def part2(input, min_coord, max_coord)
  grid = Grid.parse(input)
  missing_beacon = grid.find_missing_beacon(min_coord, max_coord)
  missing_beacon[0] * 4_000_000 + missing_beacon[1]
end

test_input = <<-INPUT
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
INPUT
grid = Grid.parse(test_input)
raise unless grid.sensor_at([2, 18]).closest_beacon_location == [-2, 15]
raise grid.sensor_at([8, 7]).distance_to_closest_beacon.inspect unless grid.sensor_at([8, 7]).distance_to_closest_beacon == 9
raise grid.sensor_at([8, 7]).no_beacon_spaces_x(10, -9999, 9999).inspect unless grid.sensor_at([8, 7]).no_beacon_spaces_x(10, -9999, 9999) == (3..14).to_a
raise grid.sensor_at([8, 7]).no_beacon_spaces(-9999, 9999).size.inspect unless grid.sensor_at([8, 7]).no_beacon_spaces(-9999, 9999).size == 180
raise grid.no_beacon_spaces_x(10, -9999, 9999).inspect unless grid.no_beacon_spaces_x(10, -9999, 9999).size == 26
result = part2(test_input, 0, 20)
raise result.inspect unless result == 56000011

# grid.sensors.each do |s|
#   puts "#{s.location.inspect} - #{s.no_beacon_spaces_x(10).inspect}"
# end

# # part1
# input = File.read("input.txt")
# puts "part1 - #{part1(input)}"
#
# part2
# input = File.read("input.txt")
# puts "part2 - #{part2(input, 0, 4_000_000)}"
