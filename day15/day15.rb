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

  def no_beacon_spaces_x(y)
    min_x = location[0] - (distance_to_closest_beacon - (y - location[1]).abs)
    max_x = location[0] + (distance_to_closest_beacon - (y - location[1]).abs)
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

  def no_beacon_spaces_x(y)
    sensors.map { |s| s.no_beacon_spaces_x(y) }.flatten.uniq.sort
  end
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
raise grid.sensor_at([8, 7]).no_beacon_spaces_x(10).inspect unless grid.sensor_at([8, 7]).no_beacon_spaces_x(10) == (3..14).to_a
raise grid.no_beacon_spaces_x(10).inspect unless grid.no_beacon_spaces_x(10).size == 26

# grid.sensors.each do |s|
#   puts "#{s.location.inspect} - #{s.no_beacon_spaces_x(10).inspect}"
# end

input = File.read("input.txt")
grid = Grid.parse(input)
puts "part1 - #{grid.no_beacon_spaces_x(2000000).size}"