const fs = require('fs');

const sum = (arr) => arr.reduce((accumulator, value) => {
    return accumulator + value;
  }, 0);

const part1 = (input) => {
    return input
        .split("\n\n")
        .map(a => sum(a.split("\n").map(a => parseInt(a))))
        .sort((a, b) => (a - b))
        .reverse()[0]
}

const part2 = (input) => {
    const elves = input
        .split("\n\n")
        .map(a => sum(a.split("\n").map(a => parseInt(a))))
        .sort((a, b) => (a - b))
        .reverse()
        .slice(0, 3);
    return sum(elves);
}

const test_input = 
`1000
2000
3000

4000

5000
6000

7000
8000
9000

10000`;
let result = part1(test_input);
if (result != 24000) {
    throw(result)
}

result = part2(test_input);
if (result != 45000) {
    throw(result)
}

const input = fs.readFileSync("input.txt", "utf8");
console.log(`part1 - ${part1(input)}`);
console.log(`part2 - ${part2(input)}`);
