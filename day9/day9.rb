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
# (I drastically over-complicated this and should've read the requirements better to find the patterns)
TRANSFORMS = {
  # H on top of T
  [0,0,-1,0] => [0,0], # left
  [0,0,1,0] => [0,0], # right
  [0,0,0,1] => [0,0], # up
  [0,0,0,-1] => [0,0], # down
  [0,0,-1,1] => [0,0], # up/left
  [0,0,1,1] => [0,0], # up/right
  [0,0,-1,-1] => [0,0], # down/left
  [0,0,1,-1] => [0,0], # down/right
  [0,0,0,0] => [0,0], # no move
  # HT
  [1,0,-1,0] => [-1,0], # left
  [1,0,1,0] => [0,0], # right
  [1,0,0,1] => [0,0], # up
  [1,0,0,-1] => [0,0], # down
  [1,0,-1,1] => [-1,1], # up/left
  [1,0,1,1] => [0,0], # up/right
  [1,0,-1,-1] => [-1,-1], # down/left
  [1,0,1,-1] => [0,0], # down/right
  [1,0,0,0] => [0,0], # no move
  # TH
  [-1,0,-1,0] => [0,0], # left
  [-1,0,1,0] => [1,0], # right
  [-1,0,0,1] => [0,0], # up
  [-1,0,0,-1] => [0,0], # down
  [-1,0,-1,1] => [0,0], # up/left
  [-1,0,1,1] => [1,1], # up/right
  [-1,0,-1,-1] => [0,0], # down/left
  [-1,0,1,-1] => [1,-1], # down/right
  [-1,0,0,0] => [0,0], # no move
  # H
  # T
  [0,-1,-1,0] => [0,0], # left
  [0,-1,1,0] => [0,0], # right
  [0,-1,0,1] => [0,1], # up
  [0,-1,0,-1] => [0,0], # down
  [0,-1,-1,1] => [-1,1], # up/left
  [0,-1,1,1] => [1,1], # up/right
  [0,-1,-1,-1] => [0,0], # down/left
  [0,-1,1,-1] => [0,0], # down/right
  [0,-1,0,0] => [0,0], # no move
  # T
  # H
  [0,1,-1,0] => [0,0], # left
  [0,1,1,0] => [0,0], # right
  [0,1,0,1] => [0,0], # up
  [0,1,0,-1] => [0,-1], # down
  [0,1,-1,1] => [0,0], # up/left
  [0,1,1,1] => [0,0], # up/right
  [0,1,-1,-1] => [-1,-1], # down/left
  [0,1,1,-1] => [1,-1], # down/right
  [0,1,0,0] => [0,0], # no move
  #  T
  # H
  [1,1,-1,0] => [-1,-1], # left
  [1,1,1,0] => [0,0], # right
  [1,1,0,1] => [0,0], # up
  [1,1,0,-1] => [-1,-1], # down
  [1,1,-1,1] => [-1,0], # up/left
  [1,1,1,1] => [0,0], # up/right
  [1,1,-1,-1] => [-1,-1], # down/left
  [1,1,1,-1] => [0,-1], # down/right
  [1,1,0,0] => [0,0], # no move
  # T
  #  H
  [-1,1,-1,0] => [0,0], # left
  [-1,1,1,0] => [1,-1], # right
  [-1,1,0,1] => [0,0], # up
  [-1,1,0,-1] => [1,-1], # down
  [-1,1,-1,1] => [0,0], # up/left
  [-1,1,1,1] => [1,0], # up/right
  [-1,1,-1,-1] => [0,-1], # down/left
  [-1,1,1,-1] => [1,-1], # down/right
  [-1,1,0,0] => [0,0], # no move
  # H
  #  T
  [1,-1,-1,0] => [-1,1], # left
  [1,-1,1,0] => [0,0], # right
  [1,-1,0,1] => [-1,1], # up
  [1,-1,0,-1] => [0,0], # down
  [1,-1,-1,1] => [-1,1], # up/left
  [1,-1,1,1] => [0,1], # up/right
  [1,-1,-1,-1] => [-1,0], # down/left
  [1,-1,1,-1] => [0,0], # down/right
  [1,-1,0,0] => [0,0], # no move
  #  H
  # T
  [-1,-1,-1,0] => [0,0], # left
  [-1,-1,1,0] => [1,1], # right
  [-1,-1,0,1] => [1,1], # up
  [-1,-1,0,-1] => [0,0], # down
  [-1,-1,-1,1] => [0,1], # up/left
  [-1,-1,1,1] => [1,1], # up/right
  [-1,-1,-1,-1] => [0,0], # down/left
  [-1,-1,1,-1] => [1,0], # down/right
  [-1,-1,0,0] => [0,0], # no move
}

def process_move(sections, actions)
  action = actions.shift
  head_transform = HEAD_TRANSFORMS[action]

  sections.each_with_index do |section, index|
    head = section
    tail = sections[index + 1]

    previous_head_location = head.location
    head.move(*head_transform)
    # puts("move #{head_transform.inspect} from #{previous_head_location.inspect} to #{head.location.inspect}")

    if tail
      transform_key = [tail.x - previous_head_location[0], tail.y - previous_head_location[1], *head_transform]
      tail_transform = TRANSFORMS[transform_key]
      # puts("transform for #{transform_key.inspect} is #{tail_transform.inspect}")
      raise "missing tail transform for #{transform_key}" unless tail_transform

      head_transform = tail_transform
    end
  end

  # puts("now at #{sections.map(&:location).inspect}")

  [sections, actions]
end

def process_actions(sections, actions)
  while actions.any?
    sections, actions = process_move(sections, actions)
  end
  print_grid(sections)
  print_grid(sections, sections.last.visited_locations)
  sections
end

def print_grid(sections, visited_locations = nil)
  puts("grid:")
  x_locations = sections.map { |section| section.visited_locations.map { |x, _| x } }.flatten
  y_locations = sections.map { |section| section.visited_locations.map { |_, y| y } }.flatten

  grid = ((y_locations.min)..(y_locations.max)).to_a.reverse.map do |y|

    this_row_visited_locations = visited_locations&.any? ? visited_locations.select { |_, loc_y| loc_y == y} : []
    ((x_locations.min)..(x_locations.max)).map do |x|
      sections_at_location = []
      sections.each_with_index do |section, i|
        sections_at_location << i if section.location == [x, y]
      end

      if visited_locations&.any?
        if this_row_visited_locations.include?([x,y])
          "#"
        elsif y == 0
          "-"
        elsif x == 0
          "|"
        else
          "."
        end
      else
        if sections_at_location.any?
          sections_at_location.min.to_s
        elsif x == 0 && y == 0
          "s"
        elsif y == 0
          "-"
        elsif x == 0
          "|"
        else
          "."
        end
      end
    end.join + "\n"
  end.join
  puts grid
end

def run(input, rope_size)
  sections = (0...rope_size).map { |_| Section.new(0,0) }
  actions = input.split("\n").map { |line| line.split(" ") }.map { |direction, amount| [direction] * amount.to_i }.flatten

  sections = process_actions(sections, actions)

  # puts "visited locations - #{sections.last.visited_locations.sort.inspect}"
  sections.last.visited_locations.size
end

# make sure I created the transforms array correctly
raise unless TRANSFORMS.size == 81

sections = (0..8).map { |i|  TRANSFORMS.keys.transpose[2].slice((9*i)...(9*(i+1))) }
raise unless sections.uniq.size == 1

sections = (0..8).map { |i|  TRANSFORMS.keys.transpose[2].slice((9*i)...(9*(i+1))) }
raise unless sections.uniq.size == 1

raise unless TRANSFORMS.keys.transpose.map(&:sum) == [0,0,0,0]

values_sections = (0..1).map { |i| TRANSFORMS.values.transpose[0].slice((9+(36*i)...9+(36*(i+1)))) }
raise values_sections.map(&:sum).inspect unless values_sections.map(&:sum) == [0,0]
raise values_sections.map(&:size).inspect unless values_sections.map(&:size) == [36,36]
values_sections = (0..1).map { |i| TRANSFORMS.values.transpose[1].slice((9+(36*i)...9+(36*(i+1)))) }
raise values_sections.map(&:sum).inspect unless values_sections.map(&:sum) == [0,0]
raise values_sections.map(&:size).inspect unless values_sections.map(&:size) == [36,36]

puts(TRANSFORMS.keys.transpose.map(&:sum))
puts(TRANSFORMS.keys.transpose.inspect)

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
result = run(test_input, 2)
raise result.inspect unless result == 13

sections = 3.times.collect { Section.new(0,0) }
actions = ["R"]
sections, actions = process_move(sections, actions)
raise unless sections[0].location == [1,0]
raise unless sections[1].location == [0,0]
raise unless sections[2].location == [0,0]

sections = 9.times.collect { Section.new(0,0) }
actions = (["R"] * 4) + (["U"] * 2)
sections = process_actions(sections, actions)
raise unless sections[0].location == [4,2]
raise unless sections[1].location == [4,1]
raise unless sections[2].location == [3,1]
raise unless sections[3].location == [2,1]
raise unless sections[4].location == [1,1]
raise unless sections[5].location == [0,0]


test_input = <<-INPUT
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
INPUT
result = run(test_input, 10)
raise result.inspect unless result == 36

input = File.read("input.txt")
puts "part1 = #{run(input, 2)}"
puts "part2 = #{run(input, 10)}"
