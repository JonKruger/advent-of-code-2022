def combine_ranges(ranges)
  raise ranges.inspect unless ranges.is_a?(Array)
  combined_something = false
  ranges = ranges.sort_by { |r| r.begin }.reduce([]) do |result, range|
    last = result.last
    if last.nil?
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
  puts(ranges.inspect)

  combined_something ? combine_ranges(ranges) : ranges
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

  def no_beacon_spaces
    @no_beacon_spaces ||= begin
                            min_y = [location[1] - distance_to_closest_beacon, @min_coord].max
                            max_y = [location[1] + distance_to_closest_beacon, @max_coord].min
                            (min_y..max_y).reduce([]) do |spaces, y|
                              puts "... calculating no beacon spaces for #{y}"
                              spaces += no_beacon_spaces_x(y).map { |x| [x, y] }
                            end
                          end
  end

  def no_beacon_spaces_x(y)
    @no_beacon_spaces_x[y] ||= begin
                                 # start = Time.now
                                 # puts start.to_f
                                 # puts "0 #{Time.now - start}"
                                 min_x = [location[0] - (distance_to_closest_beacon - (y - location[1]).abs), @min_coord].max
                                 # puts "1 #{Time.now - start}"
                                 max_x = [location[0] + (distance_to_closest_beacon - (y - location[1]).abs), @max_coord].min
                                 # puts "2 #{Time.now - start}"
                                 spaces = (min_x..max_x).to_a
                                 # puts "3 #{Time.now - start}"
                                 spaces -= [closest_beacon_location[0]] if closest_beacon_location[1] == y
                                 # puts "4 #{Time.now - start}"
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
    sensors.map { |s| s.no_beacon_spaces_x(y) }.flatten.uniq.sort
  end

  def no_beacon_spaces
    @no_beacon_spaces ||= begin
                            sensors.reduce([]) do |spaces, s|
                              sensor_no_beacon_spaces = s.no_beacon_spaces
                              puts("sensor #{s.location.inspect} has #{sensor_no_beacon_spaces.size} no beacon spaces")
                              spaces += sensor_no_beacon_spaces
                            end.uniq - beacon_locations
                          end
  end

  def beacon_locations
    @beacon_locations ||= sensors.map { |s| s.closest_beacon_location }.uniq
  end

  def find_missing_beacon
    puts("find_missing_beacon")
    # puts("#{(no_beacon_spaces + beacon_locations).size} spaces to process")
    hash = {}

    (@min_coord..@max_coord).each do |y|
      start = Time.now

      x_locations = (sensors.map { |s| s.no_beacon_spaces_x(y) } + beacon_locations.select { |_, y_loc| y_loc == y }.map { |x_loc, _| x_loc }).flatten.uniq
      if x_locations.size != @max_coord - @min_coord + 1
        return [((@min_coord..@max_coord).to_a - x_locations)[0], y]
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
  grid = Grid.parse(input, -9000000000, 9000000000)
  grid.no_beacon_spaces_x(2000000).size
end

def part2(input, min_coord, max_coord)
  grid = Grid.parse(input, min_coord, max_coord )
  missing_beacon = grid.find_missing_beacon
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
raise grid.sensor_at([8, 7]).no_beacon_spaces_x(10).inspect unless grid.sensor_at([8, 7]).no_beacon_spaces_x(10) == (3..14).to_a
raise grid.sensor_at([8, 7]).no_beacon_spaces.size.inspect unless grid.sensor_at([8, 7]).no_beacon_spaces.size == 180
raise grid.no_beacon_spaces_x(10).inspect unless grid.no_beacon_spaces_x(10).size == 26

result = part2(test_input, 0, 20)
raise result.inspect unless result == 56000011

# grid.sensors.each do |s|
#   puts "#{s.location.inspect} - #{s.no_beacon_spaces_x(10).inspect}"
# end

# part1
# input = File.read("input.txt")
# puts "part1 - #{part1(input)}"
#
# part2
# input = File.read("input.txt")
# puts "part2 - #{part2(input, 0, 4_000_000)}"
