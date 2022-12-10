class Location
  attr_reader :x, :y
  attr_accessor :visited

  def initialize(x, y)
    @x = x
    @y = y
    @visited = false
  end
end

class Section
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    @visited_locations = [[x,y]]
  end

  def move(x_transform, y_transform)
    @x += x_transform
    @y += y_transform
    @visited_locations << [x,y]
    nil
  end

  def location
    [x,y]
  end

  def visited_locations
    @visited_locations.uniq.freeze
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

def process_move(sections, actions)
  action = actions.shift
  head_transform = HEAD_TRANSFORMS[action]

  # puts("move #{head_transform.inspect} from #{sections.map(&:location).inspect}...")

  sections.each_with_index do |section, index|
    head = section
    tail = sections[index + 1]

    next unless tail

    previous_head_location = head.location
    head.move(*head_transform)

    transform_key = [tail.x - previous_head_location[0], tail.y - previous_head_location[1], head_transform[0], head_transform[1]]
    tail_transform = TRANSFORMS[transform_key]
    raise "missing tail transform for #{transform_key}" unless tail_transform

    tail.move(*tail_transform)
    head_transform = tail_transform
  end

  # puts("... to #{sections.map(&:location).inspect}")

  [sections, actions]
end

def part1(input, rope_size)
  sections = (0...rope_size).map { |_| Section.new(0,0) }
  actions = input.split("\n").map { |line| line.split(" ") }.map { |direction, amount| [direction] * amount.to_i }.flatten

  while actions.any?
    sections, actions = process_move(sections, actions)
  end
  puts "visited locations - #{sections.last.visited_locations.sort.inspect}"
  sections.last.visited_locations.size
end

sections = [Section.new(0,0), Section.new(0,0)]
actions = ["R"]
sections, actions = process_move(sections, actions)
raise unless sections[0].location == [1,0]
raise unless sections[1].location == [0,0]

sections = [Section.new(1,0), Section.new(0,0)]
actions = ["R"]
sections, actions = process_move(sections, actions)
raise unless sections[0].location == [2,0]
raise unless sections[1].location == [1,0]

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
result = part1(test_input, 2)
raise result.inspect unless result == 13

# result = part2(test_input)
# raise result.inspect unless result == 8

input = File.read("input.txt")
puts "part1 = #{part1(input, 2)}"
# puts "part2 = #{part2(input)}"
