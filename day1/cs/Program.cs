int Part1(string[] inputLines)
{
    return string.Join(",", inputLines)
        .Split(",,")
        .Select(a => 
        {
            return a.Split(",")
                .Select(a => int.Parse(a))
                .Sum();
        })
        .OrderByDescending(a => a)
        .ToList()[0];
}

int Part2(string[] inputLines)
{
    return string.Join(",", inputLines)
        .Split(",,")
        .Select(a => 
        {
            return a.Split(",")
                .Select(a => int.Parse(a))
                .Sum();
        })
        .OrderByDescending(a => a)
        .ToList()
        .Take(3)
        .Sum();
}

var testInput = @"1000
2000
3000

4000

5000
6000

7000
8000
9000

10000".Split("\r\n");

var result = Part1(testInput);
if (result != 24000)
    throw new Exception(result.ToString());

result = Part2(testInput);
if (result != 45000)
    throw new Exception(result.ToString());

var input = File.ReadAllLines("../input.txt");
Console.WriteLine($"part1 - {Part1(input)}");
Console.WriteLine($"part2 - {Part2(input)}");

