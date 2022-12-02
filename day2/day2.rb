
def part1(input)
    scores = {
      "A X" => 4, # 3 + 1
      "A Y" => 8, # 6 + 2
      "A Z" => 3, # 0 + 3
      "B X" => 1, # 0 + 1
      "B Y" => 5, # 3 + 2
      "B Z" => 9, # 6 + 3
      "C X" => 7, # 6 + 1
      "C Y" => 2, # 0 + 2
      "C Z" => 6, # 3 + 3
    }
    input.split("\n").map { |row| scores[row.strip] }.compact.sum
end
  
  test_input = <<-INPUT
A Y
B X
C Z
  INPUT
  result = part1(test_input)
  raise result.inspect if result != 15
  
  # result = part2(test_input)
  # raise result.inspect if result != 45000
  
  input = File.read("input.txt")
  puts "part1 - #{part1(input)}"
  # puts "part2 - #{part2(input)}"
  