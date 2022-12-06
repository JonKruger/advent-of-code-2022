import java.io.File

fun main() {
    var testInput = "mjqjpqmgbljsphdztnvjfqwrcgsmlb";
    var result = run(testInput, 4);
    if (result != 7) {
        throw Exception(result.toString());
    }

    testInput = "aaaaasdf";
    result = run(testInput, 4);
    if (result != 8) {
        throw Exception(result.toString());
    }

    testInput = "mjqjpqmgbljsphdztnvjfqwrcgsmlb";
    result = run(testInput, 14);
    if (result != 19) {
        throw Exception(result.toString());
    }

    val input = File("input.txt").readText();
    val part1Result = run(input, 4);
    val part2Result = run(input, 14);
    println("part1 - $part1Result");
    println("part2 - $part2Result");
}

fun run(input: String, messageSize: Int): Int? {
    val inputArray = input.split("");
    (1..(inputArray.size - messageSize - 1)).forEach { startIndex -> 
        val group = inputArray.slice(startIndex..(startIndex + messageSize - 1));
        if (group.size == messageSize && HashSet<String>(group).size == messageSize)
            return startIndex + messageSize - 1;
    };
    return null;
}
