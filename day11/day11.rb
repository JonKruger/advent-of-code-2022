class Monkey
  attr_reader :items, :operation, :test, :if_true, :if_false
  attr_accessor :items_inspected

  def initialize(starting_items:, operation:, test:, if_true:, if_false:)
    @items = starting_items
    @operation = operation
    @test = test
    @if_true = if_true
    @if_false = if_false
    @items_inspected = 0
  end
end

def inspect_items(monkeys, number_of_rounds)
  number_of_rounds.times do
    monkeys.each_with_index do |monkey, monkey_index|
      # On a single monkey's turn, it inspects and throws all of the items it is holding one at a
      # time and in the order listed.
      while item = monkey.items.shift
        # puts "Monkey #{monkey_index} inspects an item with a worry level of #{item}"
        monkey.items_inspected += 1
        new_value = monkey.operation.call(item)
        # puts "  Worry level changes to #{new_value}"
        new_value = (new_value / 3).to_i
        # puts "  Monkey gets bored with item. Worry level is divided by 3 to #{new_value}"
        if monkey.test.call(new_value)
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
  result.map(&:items_inspected).sort.reverse[0..1].reduce(:*)
end

def test_monkeys
  [
    Monkey.new(
      starting_items: [79, 98],
      operation: -> (old) { old * 19 },
      test: -> (value) { value % 23 == 0 },
      if_true: 2,
      if_false: 3
    ),
    Monkey.new(
      starting_items: [54, 65, 75, 74],
      operation: -> (old) { old + 6 },
      test: -> (value) { value % 19 == 0 },
      if_true: 2,
      if_false: 0
    ),
    Monkey.new(
      starting_items: [79, 60, 97],
      operation: -> (old) { old * old },
      test: -> (value) { value % 13 == 0 },
      if_true: 1,
      if_false: 3
    ),
    Monkey.new(
      starting_items: [74],
      operation: -> (old) { old + 3 },
      test: -> (value) { value % 17 == 0 },
      if_true: 0,
      if_false: 1
    )
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