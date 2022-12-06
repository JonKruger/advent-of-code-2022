import java.io.File

fun main() {
    var testStackInput =
        """
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 
        """.trimIndent();

    var testMoveInput =
        """
move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
        """.trimIndent();

    var stacks = parseStackInput(testStackInput);
    if (stacks.size != 3)
        throw Exception("incorrect stack size - " + stacks.size);
    var stack1 = stacks[0].joinToString("");
    if (stack1 != "ZN")
        throw Exception("incorrect stack 1 - " + stack1);
    var stack2 = stacks[1].joinToString("");
    if (stack2 != "MCD")
        throw Exception("incorrect stack 2 - " + stack2);
    var stack3 = stacks[2].joinToString("");
    if (stack3 != "P")
        throw Exception("incorrect stack 3 - " + stack3);

    var moves = parseMoveInput(testMoveInput);
    if (moves.size != 4)
        throw Exception("incorrect move size - " + moves.size);
    if (moves[0].toString() != "[1, 2, 1]")
        throw Exception("incorrect move 1 - " + moves[0].toString());

    var result = part1(testStackInput, testMoveInput);
    if (result != "CMZ") {
        throw Exception(result.toString());
    }

    result = part2(testStackInput, testMoveInput);
    if (result != "MCD") {
        throw Exception(result.toString());
    }

    var stacksInput = File("input_stacks.txt").readText();
    var movesInput = File("input_moves.txt").readText();
    val part1Result = part1(stacksInput, movesInput);
    val part2Result = part2(stacksInput, movesInput);
    println("part1 - $part1Result");
    println("part2 - $part2Result");
}

fun parseStackInput(stackInput: String): MutableList<ArrayDeque<String>> {
    var lines = stackInput.split("\n");
    val stackCount = lines.last().split(" ").filter { x -> x.trim().length > 0 }.last().toInt();

    var allStackLines = lines.slice(0..(lines.size - 2));
    var stacks = (1..stackCount).map { index ->
        var stackLines = allStackLines.map { line -> 
            var startIndex = (index - 1) * 4;
            var endIndex = startIndex + 2;
            line.slice(startIndex..endIndex);
        }; 
        
        var stack = ArrayDeque<String>();
        stackLines.reversed().forEach { line -> 
            var letter = line.replace("[", "").replace("]", "").trim();
            if (letter.length > 0)
                stack.add(letter);
        };
        stack
    }.toMutableList();

    return stacks;
}

fun parseMoveInput(moveInput: String): List<List<Int>> {
    return moveInput.split("\n")
        .map { line -> line.split(" ").slice(setOf(1, 3, 5)).map { item -> item.toInt() } };
}

fun part1(stackInput: String, moveInput: String): String {
    var stacks = parseStackInput(stackInput);
    var moves = parseMoveInput(moveInput);

    moves.forEach { move -> 
        val (times, fromStack, toStack) = move;
        (1..times).forEach { 
            var item = stacks[fromStack - 1].removeLast();
            stacks[toStack - 1].add(item);
        }
    };

    return stacks.map { stack -> stack.removeLast() }.joinToString("");
}

fun part2(stackInput: String, moveInput: String): String {
    var stacks = parseStackInput(stackInput);
    var moves = parseMoveInput(moveInput);

    moves.forEach { move -> 
        val (times, fromStackNumber, toStackNumber) = move;
        var fromStack = stacks[fromStackNumber - 1];
        var toStack = stacks[toStackNumber - 1];

        var items = fromStack.slice((fromStack.size - times)..(fromStack.size - 1));
        fromStack = ArrayDeque<String>(fromStack.slice(0..(fromStack.size - times - 1)));
        stacks.set(fromStackNumber - 1, fromStack);
        toStack.addAll(items);
    };

    return stacks.map { stack -> stack.removeLast() }.joinToString("");
}