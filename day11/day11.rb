class Monkey
  attr_reader :operation, :divisible_by, :if_true, :if_false
  attr_accessor :items_inspected, :items

  def initialize(starting_items:, operation:, divisible_by:, if_true:, if_false:)
    @items = starting_items
    @operation = operation
    @divisible_by = divisible_by
    @if_true = if_true
    @if_false = if_false
    @items_inspected = 0
  end
end

def inspect_items(monkeys, number_of_rounds, divide_by_3: true)
  common_denominator = monkeys.map(&:divisible_by).reduce(:*)
  number_of_rounds.times do |round|
    puts("***** ROUND #{round}")
    monkeys.each_with_index do |monkey, monkey_index|
      # On a single monkey's turn, it inspects and throws all of the items it is holding one at a
      # time and in the order listed.
      while item = monkey.items.shift
        # puts "Monkey #{monkey_index} inspects an item with a worry level of #{item}"
        monkey.items_inspected += 1
        new_value = monkey.operation.call(item)
        # puts "  Worry level changes to #{new_value}"
        if divide_by_3
          new_value = (new_value / 3).to_i
          # puts "  Monkey gets bored with item. Worry level is divided by 3 to #{new_value}"
        end

        # (I had to look this one up, I admit)
        new_value %= common_denominator

        if new_value % monkey.divisible_by == 0
          # puts "  Current worry level is divisible"
          # puts "  Item with worry level #{new_value} is thrown to monkey #{monkey.if_true}"
          monkeys[monkey.if_true].items << new_value
        else
          # puts "  Current worry level is not divisible"
          # puts "  Item with worry level #{new_value} is thrown to monkey #{monkey.if_false}"
          monkeys[monkey.if_false].items << new_value
        end
      end
    end
  end

  monkeys
end

def part1(monkeys)
  result = inspect_items(monkeys, 20)
  puts(result.map(&:items_inspected).inspect)
  result.map(&:items_inspected).sort.reverse[0..1].reduce(:*)
end

def part2(monkeys)
  result = inspect_items(monkeys, 10000, divide_by_3: false)
  puts(result.map(&:items_inspected).inspect)
  result.map(&:items_inspected).sort.reverse[0..1].reduce(:*)
end

def test_monkeys
  [
    Monkey.new(
      starting_items: [79, 98],
      operation: -> (old) { old * 19 },
      divisible_by: 23,
      if_true: 2,
      if_false: 3
    ),
    Monkey.new(
      starting_items: [54, 65, 75, 74],
      operation: -> (old) { old + 6 },
      divisible_by: 19,
      if_true: 2,
      if_false: 0
    ),
    Monkey.new(
      starting_items: [79, 60, 97],
      operation: -> (old) { old * old },
      divisible_by: 13,
      if_true: 1,
      if_false: 3
    ),
    Monkey.new(
      starting_items: [74],
      operation: -> (old) { old + 3 },
      divisible_by: 17,
      if_true: 0,
      if_false: 1
    )
  ]
end

def real_monkeys
  [
    Monkey.new(
      starting_items: [72, 97],
      operation: -> (old) { old * 13 },
      divisible_by: 19,
      if_true: 5,
      if_false: 6
    ),
    Monkey.new(
      starting_items: [55, 70, 90, 74, 95],
      operation: -> (old) { old * old },
      divisible_by: 7,
      if_true: 5,
      if_false: 0
    ),
    Monkey.new(
      starting_items: [74, 97, 66, 57],
      operation: -> (old) { old + 6 },
      divisible_by: 17,
      if_true: 1,
      if_false: 0
    ),
    Monkey.new(
      starting_items: [86, 54, 53],
      operation: -> (old) { old + 2 },
      divisible_by: 13,
      if_true: 1,
      if_false: 2
    ),
    Monkey.new(
      starting_items: [50, 65, 78, 50, 62, 99],
      operation: -> (old) { old + 3 },
      divisible_by: 11,
      if_true: 3,
      if_false: 7
    ),
    Monkey.new(
      starting_items: [90],
      operation: -> (old) { old + 4 },
      divisible_by: 2,
      if_true: 4,
      if_false: 6
    ),
    Monkey.new(
      starting_items: [88, 92, 63, 94, 96, 82, 53, 53],
      operation: -> (old) { old + 8 },
      divisible_by: 5,
      if_true: 4,
      if_false: 7
    ),
    Monkey.new(
      starting_items: [70, 60, 71, 69, 77, 70, 98],
      operation: -> (old) { old * 7 },
      divisible_by: 3,
      if_true: 2,
      if_false: 3
    ),
  ]
end

result = inspect_items(test_monkeys, 20)
raise result[0].items.inspect unless result[0].items == [10, 12, 14, 26, 34]
raise result[1].items.inspect unless result[1].items == [245, 93, 53, 199, 115]
raise result[2].items.inspect if result[2].items.any?
raise result[3].items.inspect if result[3].items.any?

items_inspected = result.map(&:items_inspected)
raise items_inspected.inspect unless items_inspected == [101, 95, 7, 105]

result = part1(test_monkeys)
raise result.inspect unless result == 10605

result = part1(real_monkeys)
puts "part1 - #{result}"

result = part2(real_monkeys)
puts "part2 - #{result}"
