import java.io.File

fun main() {
    var testInput =
        """
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
        """.trimIndent();

    var result = part1(testInput);
    if (result != 24000) {
        throw Exception(result.toString());
    }

    result = part2(testInput);
    if (result != 45000) {
        throw Exception(result.toString());
    }

    var input = File("input.txt").readText();
    val part1Result = part1(input);
    val part2Result = part2(input);
    println("part1 - $part1Result");
    println("part2 - $part2Result");
}

fun groupValue(group: String): Int {
    return group.split("\n").map { it: String -> it.toInt() }.sum();
}

fun part1(input: String): Int {
    var groups = input.split("\n\n");
    return groups.map { it: String -> groupValue(it) }.max();
}

fun part2(input: String): Int {
    var groups = input.split("\n\n");
    return groups.map { it: String -> groupValue(it) }.sortedDescending().slice(0..2).sum()
}