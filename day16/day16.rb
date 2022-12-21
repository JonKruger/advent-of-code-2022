class Valve
  attr_reader :name, :flow_rate, :leads_to

  def initialize(name, flow_rate, leads_to)
    @name = name.freeze
    @flow_rate = flow_rate.freeze
    @leads_to = leads_to.freeze
    @open = false
  end

  def open?
    @open
  end

  def closed?
    !@open
  end

  def can_move_to?(new_location)
    leads_to.include?(new_location)
  end

  def open
    @open = true
  end
end

class ValuePath
  attr_reader :path, :flow_rate
  def initialize(path, flow_rate)
    @path = path.freeze
    @flow_rate = flow_rate.freeze
  end

  def start_location
    @start_location ||= path.first
  end

  def destination
    @destination ||= path.last
  end

  def distance
    @distance ||= path.size - 1
  end

  def flow_possible_in(minutes)
    flow_minutes = minutes - distance - 1
    flow_minutes * flow_rate
  end

  def flow_per_minute
    @flow_per_minute ||= flow_rate.to_f / distance.to_f
  end
end

class Map
  def self.parse(input, time_limit)
    lines = input.split("\n")
    valves = {}
    lines.each do |line|
      match = /Valve\s([A-Z]+)\shas\sflow\srate=([0-9]+);\stunnels?\sleads?\sto\svalves?\s([A-Z,\s]+)$/.match(line)
      raise line.inspect unless match
      valve = Valve.new(match[1], match[2].to_i, match[3].split(", "))
      valves[valve.name] = valve
    end
    map = Map.new(valves, time_limit)
    map.map_value_paths
    map
  end

  attr_reader :time_elapsed, :current_location, :pressure_released, :time_limit

  def initialize(valve_hash, time_limit)
    @valve_hash = valve_hash
    @time_elapsed = 0
    @current_location = "AA"
    @pressure_released = 0
    @time_limit = time_limit
  end

  def time_left
    time_limit - time_elapsed
  end

  def [](name)
    @valve_hash[name]
  end

  def valves
    @valve_hash.values.dup
  end

  def flow_rate
    valves.select(&:open?).map(&:flow_rate).sum
  end

  def current_valve
    @valve_hash[current_location]
  end

  def move_to(new_location)
    raise "no tunnel from #{current_location} to #{new_location}" unless current_valve.can_move_to?(new_location)
    @current_location = new_location
    tick
  end

  def travel_value_path(value_path)
    raise unless current_location == value_path.start_location
    value_path.path[1..].each { |location| move_to(location) }
  end

  def open_valve
    tick
    current_valve.open
    @value_paths = @value_paths.select { |path| path.destination != current_location }
  end

  def tick
    @time_elapsed += 1
    @pressure_released += flow_rate
  end

  def map_value_paths
    @value_paths = valves.map do |valve|
      # puts("starting #{valve.name}")
      paths = identify_next_stops([valve.name])
      # puts("result is #{paths}")
      paths.map do |path|
        # puts("creating #{path.inspect}")
        ValuePath.new(path, @valve_hash[path.last].flow_rate)
      end
    end.flatten
  end

  def identify_next_stops(path)
    current_valve = @valve_hash[path.last]
    if path.size > 1 && current_valve.flow_rate > 0
      # puts("done")
      return [path]
    end

    current_valve.leads_to
                 .select { |next_valve| !path.include?(next_valve) }
                 .reduce([]) do |new_paths, next_valve|
      # puts("next #{next_valve}")
      new_paths += identify_next_stops(path + [next_valve])
    end
  end

  def value_paths_from(start_location)
    @value_paths.select { |path| path.start_location == start_location }
  end

  def maximize_pressure_released
    
  end
end

test_input = <<-INPUT
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
INPUT
map = Map.parse(test_input, 30)
raise unless map["BB"].flow_rate == 13
raise unless map["BB"].leads_to.sort == ["AA", "CC"]
raise unless map["HH"].flow_rate == 22
raise unless map["HH"].leads_to.sort == ["GG"]
raise unless map.valves.all?(&:closed?)
raise unless map.flow_rate == 0
raise unless map.time_elapsed == 0
raise unless map.current_location == "AA"

raise unless map.value_paths_from("AA").size == 3
aa_jj_path = map.value_paths_from("AA").select { |path| path.destination == "JJ" }.first
raise unless aa_jj_path.distance == 2
raise unless aa_jj_path.flow_rate == 21
raise unless aa_jj_path.flow_per_minute == 10.5
raise unless aa_jj_path.flow_possible_in(3) == 0
raise unless aa_jj_path.flow_possible_in(4) == 21

begin
  map.move_to("nope")
rescue
  raise unless map.time_elapsed == 0
  raise unless map.current_location == "AA"
end

map.move_to("DD")
raise unless map.valves.all?(&:closed?)
raise unless map.flow_rate == 0
raise unless map.time_elapsed == 1
raise unless map.current_location == "DD"

map.open_valve
raise unless map["DD"].open?
raise unless map.pressure_released == 0
raise unless map.time_elapsed == 2

map.move_to("CC")
raise unless map.pressure_released == 20
raise unless map.time_elapsed == 3
raise unless map.current_location == "CC"

map = Map.parse(test_input, 30)
