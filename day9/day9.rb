class Location
  attr_reader :x, :y
  attr_accessor :visited

  def initialize(x, y)
    @x = x
    @y = y
    @visited = false
  end
end

HEAD_TRANSFORMS = {
  "U" => [0,1],
  "D" => [0,-1],
  "L" => [-1,0],
  "R" => [1,0]
}

# location of tail in relation to head (x, y), directional change of head => directional change of tail
# x,y in terms of a coordinate play (y increases as you go up)
TRANSFORMS = {
  # H on top of T
  [0,0,-1,0] => [0,0], # left
  [0,0,1,0] => [0,0], # right
  [0,0,0,1] => [0,0], # up
  [0,0,0,-1] => [0,0], # down
  # HT
  [1,0,-1,0] => [-1,0], # left
  [1,0,1,0] => [0,0], # right
  [1,0,0,1] => [0,0], # up
  [1,0,0,-1] => [0,0], # down
  # TH
  [-1,0,-1,0] => [0,0], # left
  [-1,0,1,0] => [1,0], # right
  [-1,0,0,1] => [0,0], # up
  [-1,0,0,-1] => [0,0], # down
  # H
  # T
  [0,-1,-1,0] => [0,0], # left
  [0,-1,1,0] => [0,0], # right
  [0,-1,0,1] => [0,1], # up
  [0,-1,0,-1] => [0,0], # down
  # T
  # H
  [0,1,-1,0] => [0,0], # left
  [0,1,1,0] => [0,0], # right
  [0,1,0,1] => [0,0], # up
  [0,1,0,-1] => [0,-1], # down
  #  T
  # H
  [1,1,-1,0] => [-1,-1], # left
  [1,1,1,0] => [0,0], # right
  [1,1,0,1] => [0,0], # up
  [1,1,0,-1] => [-1,-1], # down
  # T
  #  H
  [-1,1,-1,0] => [0,0], # left
  [-1,1,1,0] => [1,-1], # right
  [-1,1,0,1] => [0,0], # up
  [-1,1,0,-1] => [1,-1], # down
  # H
  #  T
  [1,-1,-1,0] => [-1,1], # left
  [1,-1,1,0] => [0,0], # right
  [1,-1,0,1] => [-1,1], # up
  [1,-1,0,-1] => [0,0], # down
  #  H
  # T
  [-1,-1,-1,0] => [0,0], # left
  [-1,-1,1,0] => [1,1], # right
  [-1,-1,0,1] => [1,1], # up
  [-1,-1,0,-1] => [0,0], # down
}

def process_move(current_head_location, current_tail_location, locations, actions)
  action = actions.shift
  head_transform = HEAD_TRANSFORMS[action]
  new_head_location = [current_head_location[0] + head_transform[0], current_head_location[1] + head_transform[1]]

  transform_key = [current_tail_location[0] - current_head_location[0], current_tail_location[1] - current_head_location[1], head_transform[0], head_transform[1]]
  tail_transform = TRANSFORMS[transform_key]
  raise "missing tail transform for #{transform_key}" unless tail_transform

  new_tail_location = [current_tail_location[0] + tail_transform[0], current_tail_location[1] + tail_transform[1]]
  # puts action, tail_transform, new_tail_location

  locations[new_tail_location] ||= Location.new(*new_tail_location)
  locations[new_tail_location].visited = true
  puts("#{action} -> #{new_head_location.inspect}, #{new_tail_location.inspect}")
  [new_head_location, new_tail_location, locations, actions]
end

def part1(input)
  locations = { [0,0] => Location.new(0,0) }
  actions = input.split("\n").map { |line| line.split(" ") }.map { |direction, amount| [direction] * amount.to_i }.flatten
  current_head_location = [0,0]
  current_tail_location = [0,0]

  while actions.any?
    current_head_location, current_tail_location, locations, actions = process_move(current_head_location, current_tail_location, locations, actions)
  end
  puts "visited locations - #{locations.select { |coords, location| location.visited }.keys.sort.inspect}"
  locations.select { |coords, location| location.visited }.size
end

test_input = <<-INPUT
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
INPUT
result = part1(test_input)
raise result.inspect unless result == 13

# result = part2(test_input)
# raise result.inspect unless result == 8

input = File.read("input.txt")
puts "part1 = #{part1(input)}"
# puts "part2 = #{part2(input)}"
