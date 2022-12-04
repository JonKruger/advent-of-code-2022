import java.io.File

fun main() {
    var testInput =
        """
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
        """.trimIndent();

    var result = part1(testInput);
    if (result != 2) {
        throw Exception(result.toString());
    }

    result = part2(testInput);
    if (result != 4) {
        throw Exception(result.toString());
    }

    var input = File("input.txt").readText();
    val part1Result = part1(input);
    val part2Result = part2(input);
    println("part1 - $part1Result");
    println("part2 - $part2Result");
}

fun part1(input: String): Int {
    return input
        .split("\n")
        .map { line -> 
            line.split(",")
                .map { section -> 
                    var bounds = section.split("-");
                    (bounds[0].toInt()..bounds[1].toInt()).toList();
                }
        }
        .filter { pair -> 
            var intersection = pair[0].intersect(pair[1]);
            intersection.size == pair[0].size || intersection.size == pair[1].size;
        }
        .size
}

fun part2(input: String): Int {
    return input
        .split("\n")
        .map { line -> 
            line.split(",")
                .map { section -> 
                    var bounds = section.split("-");
                    (bounds[0].toInt()..bounds[1].toInt()).toList();
                }
        }
        .filter { pair -> 
            var intersection = pair[0].intersect(pair[1]);
            intersection.size > 0
        }
        .size
}