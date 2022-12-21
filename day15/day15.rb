def combine_ranges(ranges)
  raise ranges.inspect unless ranges.is_a?(Array)
  raise ranges.inspect unless ranges.all? { |range| range.is_a?(Range) }
  combined_something = false

  ranges = ranges.sort_by { |r| r.begin }.reduce([]) do |result, range|
    last = result.last
    if range.size == 0
      # ignore empty ranges
    elsif last.nil?
      result << range
    elsif last.cover?(range)
      # do nothing
    elsif last.include?(range.begin)
      result.pop
      result << ((last.begin)..(range.end))
      combined_something = true
    else
      result << range
    end
    result
  end

  combined_something ? combine_ranges(ranges) : ranges
end

def split_range(range, number_to_remove)
  if range.include?(number_to_remove)
    [((range.begin)..(number_to_remove - 1)), ((number_to_remove + 1)..(range.end))].select { |range| range.size > 0 }
  else
    [range]
  end
end

result = combine_ranges([0..3, 3..4])
raise result.inspect unless result == [0..4]

result = combine_ranges([30..40, 0..3])
raise result.inspect unless result == [0..3, 30..40]

result = combine_ranges([1..2, 0..3])
raise result.inspect unless result == [0..3]

result = combine_ranges([1..2, 1..3])
raise result.inspect unless result == [1..3]

result = combine_ranges([1..3, 1..2])
raise result.inspect unless result == [1..3]

result = split_range(0..4, 3)
raise result.inspect unless result == [0..2, 4..4]

result = split_range(0..4, 0)
raise result.inspect unless result == [1..4]

result = split_range(0..4, 4)
raise result.inspect unless result == [0..3]

result = split_range(0..4, 31)
raise result.inspect unless result == [0..4]

class Sensor
  attr_reader :location, :closest_beacon_location
  def initialize(location, closest_beacon_location, min_coord, max_coord)
    @location = location.freeze
    @closest_beacon_location = closest_beacon_location.freeze
    @min_coord = min_coord.freeze
    @max_coord = max_coord.freeze
    @no_beacon_spaces_x = {}
  end

  def distance_to(other_location)
    (0..1).map { |i| (@location[i] - other_location[i]).abs }.sum
  end

  def distance_to_closest_beacon
    @distance_to_closest_beacon ||= distance_to(closest_beacon_location)
  end

  def no_beacon_spaces_x(y)
    @no_beacon_spaces_x[y] ||= begin
                                 min_x = [location[0] - (distance_to_closest_beacon - (y - location[1]).abs), @min_coord].max
                                 max_x = [location[0] + (distance_to_closest_beacon - (y - location[1]).abs), @max_coord].min
                                 spaces = (min_x..max_x)
                                 return nil if spaces.size == 0

                                 if closest_beacon_location[1] == y
                                   spaces = split_range(spaces, closest_beacon_location[0])
                                 else
                                   [spaces]
                                 end

                                 spaces
                               end
  end
end

class Grid
  def self.parse(input, min_coord, max_coord)
    lines = input.split("\n")
    sensors = lines.map do |line|
      match = /^Sensor\sat\sx=([\-0-9]+), y=([\-0-9]+): closest beacon is at x=([\-0-9]+), y=([\-0-9]+)$/.match(line)
      Sensor.new([match[1].to_i, match[2].to_i], [match[3].to_i, match[4].to_i], min_coord, max_coord)
    end

    Grid.new(sensors, min_coord, max_coord)
  end

  attr_reader :sensors

  def initialize(sensors, min_coord, max_coord)
    @sensors = sensors.freeze
    @min_coord = min_coord.freeze
    @max_coord = max_coord.freeze
  end

  def sensor_at(location)
    sensors.select { |s| s.location == location }.first
  end

  def no_beacon_spaces_x(y)
    combine_ranges(sensors.map { |s| s.no_beacon_spaces_x(y) }.flatten.compact)
  end

  def beacon_locations
    @beacon_locations ||= sensors.map { |s| s.closest_beacon_location }.uniq
  end

  def find_missing_beacon
    (@min_coord..@max_coord).each do |y|
      puts "processing #{y} #{Time.now}" if y % 10000 == 0
      beacon_x_locations = beacon_locations.select { |x_loc, y_loc| y_loc == y && x_loc >= @min_coord && x_loc <= @max_coord }.map { |x_loc, _| x_loc..x_loc }

      x_locations = combine_ranges(sensors.map { |s| s.no_beacon_spaces_x(y) }.flatten.compact + beacon_x_locations)
      if x_locations.map(&:size).sum != @max_coord - @min_coord + 1
        return [((@min_coord..@max_coord).to_a - x_locations.map(&:to_a).flatten)[0], y]
      end
    end

    raise "no missing beacon found"
  end
end

def part1(input)
  grid = Grid.parse(input, -9000000000, 9000000000)
  grid.no_beacon_spaces_x(2000000).map(&:size).sum
end

def part2(input, min_coord, max_coord)
  grid = Grid.parse(input, min_coord, max_coord )
  missing_beacon = grid.find_missing_beacon
  puts "missing beacon is at #{missing_beacon.inspect}"
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
grid = Grid.parse(test_input, -9999, 9999)
raise unless grid.sensor_at([2, 18]).closest_beacon_location == [-2, 15]
raise grid.sensor_at([8, 7]).distance_to_closest_beacon.inspect unless grid.sensor_at([8, 7]).distance_to_closest_beacon == 9
raise grid.sensor_at([8, 7]).no_beacon_spaces_x(10).inspect unless grid.sensor_at([8, 7]).no_beacon_spaces_x(10) == [3..14]
raise grid.no_beacon_spaces_x(10).inspect unless grid.no_beacon_spaces_x(10).map(&:size).sum == 26

result = part2(test_input, 0, 20)
raise result.inspect unless result == 56000011

# part1
input = File.read("input.txt")
puts "part1 - #{part1(input)}"

# part2
input = File.read("input.txt")
puts "part2 - #{part2(input, 0, 4_000_000)}"
