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

class Path
  attr_reader :time_elapsed, :current_location, :pressure_released, :time_limit, :valve_path, :value_paths,
              :open_valves, :flow_rate, :open_valves, :log

  def initialize(time_elapsed, current_location, pressure_released, time_limit, valve_path,
                 value_paths, open_valves, valve_hash, flow_rate, log)
    raise if value_paths.nil?
    @time_elapsed = time_elapsed
    @current_location = current_location
    @pressure_released = pressure_released
    @time_limit = time_limit
    @valve_path = valve_path.dup
    @value_paths = value_paths.dup
    @open_valves = open_valves.dup
    @valve_hash = valve_hash
    @flow_rate = flow_rate
    @log = log.dup
  end

  def clone
    Path.new(time_elapsed, current_location, pressure_released, time_limit, valve_path, value_paths, open_valves,
             @valve_hash, flow_rate, log)
  end

  def valves
    @valve_hash.values
  end

  def time_left
    time_limit - time_elapsed
  end

  def complete?
    time_left == 0
  end

  def current_valve
    @valve_hash[current_location]
  end

  def flow_rate
    valves.select { |v| @open_valves.include?(v.name) }.map(&:flow_rate).sum
  end

  def move_to(new_location)
    raise "no tunnel from #{current_location} to #{new_location}" unless current_valve.can_move_to?(new_location)
    tick
    @current_location = new_location
    @log << "Move to #{new_location}"
    valve_path << new_location
  end

  def tick
    raise "out of time" if time_elapsed == time_limit
    @time_elapsed += 1
    @pressure_released += flow_rate
    @log << "[#{time_elapsed}] Values #{open_valves.join(", ")} are open, releasing #{flow_rate} pressure (total #{pressure_released})"
  end

  def open_valve
    tick
    @open_valves << current_location
    @log << "Open #{current_location}"
    @flow_rate += current_valve.flow_rate
    @value_paths = @value_paths.select { |path| path.destination != current_location }
  end

  def value_paths_from(start_location)
    @value_paths.select { |value_path| value_path.start_location == start_location }
  end

  def travel_value_path(value_path)
    raise unless current_location == value_path.start_location
    value_path.path[1..].each { |location| move_to(location) }
    open_valve
  end

  def travel_all_possible_value_paths
    value_paths_from_here = value_paths_from(current_location)
    if value_paths_from_here.empty?
      # nowhere to go, just let time elapse
      time_left.times { tick }
      [self]
    else
      value_paths_from_here.map do |value_path|
        cloned_path = clone
        cloned_path.travel_value_path(value_path)
        cloned_path
      end
    end
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
    Map.new(valves.freeze, time_limit)
  end

  attr_reader :time_limit, :paths

  def initialize(valve_hash, time_limit)
    @valve_hash = valve_hash
    @time_limit = time_limit
    map_value_paths
    @paths = [
      Path.new(0, "AA", 0, time_limit, ["AA"],
               @value_paths, [], @valve_hash, 0, [])
    ]
  end

  def [](name)
    @valve_hash[name]
  end

  def valves
    @valve_hash.values
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
    paths = []

    current_valve = @valve_hash[path.last]
    if path.size > 1 && current_valve.flow_rate > 0
      # puts("done")
      paths << path
    end

    paths += current_valve.leads_to
                 .select { |next_valve| !path.include?(next_valve) }
                 .reduce([]) do |new_paths, next_valve|
      # puts("next #{next_valve}")
      new_paths += identify_next_stops(path + [next_valve])
    end

    # if there are two paths to the same place, keep the shortest one
    paths = paths.group_by(&:last).map { |last, paths_to_last| paths_to_last.sort_by(&:size).first }

    paths
  end

  def maximize_pressure_released
    while paths.any? { |path| !path.complete? }
      puts "value_path_step with #{paths.size} paths (#{paths.select(&:complete?).size} complete)"
      sleep 0.1
      value_path_step
    end
  end

  def value_path_step
    @paths = paths.map(&:travel_all_possible_value_paths).flatten
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
raise unless map.paths.size == 1
raise unless map.paths[0].open_valves.size == 0
raise unless map.paths[0].flow_rate == 0
raise unless map.paths[0].time_elapsed == 0
raise unless map.paths[0].current_location == "AA"

# one path to each open valve
raise map.paths[0].value_paths_from("AA").size.inspect unless map.paths[0].value_paths_from("AA").size == 6
aa_jj_path = map.paths[0].value_paths_from("AA").select { |path| path.destination == "JJ" }.first
raise unless aa_jj_path.distance == 2
raise unless aa_jj_path.flow_rate == 21
raise unless aa_jj_path.flow_per_minute == 10.5
raise unless aa_jj_path.flow_possible_in(3) == 0
raise unless aa_jj_path.flow_possible_in(4) == 21

begin
  map.paths[0].move_to("nope")
rescue
  raise unless map.paths[0].time_elapsed == 0
  raise unless map.paths[0].current_location == "AA"
end

map.paths[0].move_to("DD")
raise unless map.paths[0].open_valves.size == 0
raise unless map.paths[0].flow_rate == 0
raise unless map.paths[0].time_elapsed == 1
raise unless map.paths[0].current_location == "DD"

map.paths[0].open_valve
raise unless map.paths[0].open_valves == ["DD"]
raise unless map.paths[0].pressure_released == 0
raise unless map.paths[0].time_elapsed == 2

map.paths[0].move_to("CC")
raise unless map.paths[0].pressure_released == 20
raise unless map.paths[0].time_elapsed == 3
raise unless map.paths[0].current_location == "CC"

map = Map.parse(test_input, 30)
map.value_path_step
raise unless map.paths.size == 6
raise map.paths.map(&:valve_path).sort.inspect unless map.paths.map(&:valve_path).sort ==  [["AA", "BB"], ["AA", "DD"], ["AA", "DD", "CC"], ["AA", "DD", "EE"], ["AA", "DD", "EE", "FF", "GG", "HH"], ["AA", "II", "JJ"]]
raise map.paths.map(&:open_valves).sort.inspect unless map.paths.map(&:open_valves).sort == [["BB"], ["CC"], ["DD"], ["EE"], ["HH"], ["JJ"]]

map.value_path_step
raise map.paths.size.inspect unless map.paths.size == 30
path = map.paths.select { |path| path.valve_path == ["AA", "DD", "CC", "BB"] }[0]
raise path.open_valves.inspect unless path.open_valves == ["DD", "BB"]
raise path.time_elapsed.inspect unless path.time_elapsed == 5
raise path.pressure_released.inspect unless path.pressure_released == 60

map.value_path_step
map.value_path_step
map.value_path_step
map.value_path_step
map.value_path_step
# map.paths.select { |p| p.valve_path[0..4] == ["AA", "DD", "CC", "BB", "AA"]}[0].log.each { |l| puts l }
# puts map.paths.map(&:pressure_released).sort.inspect

map = Map.parse(test_input, 30)
map.maximize_pressure_released
# puts map.paths.map(&:pressure_released).sort.tally.inspect
puts map.paths.map(&:pressure_released).max

# TODO
# map_value_paths needs to go from each valve to every other valve - you might want to
# pass a closed valve to get to a more valuable one first
