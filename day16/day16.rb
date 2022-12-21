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

class Map
  def self.parse(input)
    lines = input.split("\n")
    valves = {}
    lines.each do |line|
      match = /Valve\s([A-Z]+)\shas\sflow\srate=([0-9]+);\stunnels?\sleads?\sto\svalves?\s([A-Z,\s]+)$/.match(line)
      raise line.inspect unless match
      valve = Valve.new(match[1], match[2].to_i, match[3].split(", "))
      valves[valve.name] = valve
    end
    Map.new(valves)
  end

  attr_reader :time_elapsed, :current_location, :pressure_released

  def initialize(valve_hash)
    @valve_hash = valve_hash
    @time_elapsed = 0
    @current_location = "AA"
    @pressure_released = 0
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

  def open_valve
    tick
    current_valve.open
  end

  def tick
    @time_elapsed += 1
    @pressure_released += flow_rate
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
map = Map.parse(test_input)
raise unless map["BB"].flow_rate == 13
raise unless map["BB"].leads_to.sort == ["AA", "CC"]
raise unless map["HH"].flow_rate == 22
raise unless map["HH"].leads_to.sort == ["GG"]
raise unless map.valves.all?(&:closed?)
raise unless map.flow_rate == 0
raise unless map.time_elapsed == 0
raise unless map.current_location == "AA"

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

