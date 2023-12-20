import Foundation

let path = "part2/question.txt"
let contents = try String(contentsOfFile: path, encoding: .utf8)

// I made it to an oasis. I can take a break and recharge. I have some time
// while I wait for the air to warm up so I can use the glider to get to the
// floating metal island above me.

// While I wait I will take some reading about the ecosytem.

// The readings occur over time, but I get a print out of the readings after.
// Each line is one value that is changing over time. For example
// 0 3 6 9 12 15
// 1 3 6 10 15 21
// 10 13 16 21 30 45

// The first value starts at 0 and changes to 3, 6, 9, 12 and then 15
// The second value starts at 1 and changes to 3, 6, 10, 15 and then 21
// The third value starts at 10 and changes to 13, 16, 21, 30 and then 45

let lines = contents.components(separatedBy: "\n").dropLast()
let values = lines.map { $0.components(separatedBy: " ").map { Int($0)! } }

// To help protect the environment I should make a prediction about what
// the next readings for each value will be.

// To do this I need to reduce the differences down to a single sequence
// of all zeros. I do this by taking the difference between each number in
// the sequence and making that my new sequence repeating until the sequence
// is all zeros.

// For example
// 0   3   6   9  12  15
//   3   3   3   3   3
//     0   0   0   0
// OR
// 1   3   6  10  15  21
//   2   3   4   5   6
//     1   1   1   1
//       0   0   0

// Once I have this base sequence, I can add a 0 to the end of it
// then work backwards up the sequences to get the next values.
// Until I am back to the original sequence and have the new value.

// I should proably write a recusive function that finds this base sequence,
// then on the way back up it adds the values to the end of the sequence.

extension Sequence where Element == Int {
  // gives the difference between each element in the sequence
  // ie 0, 1, 2, 3 -> 1, 1, 1
  func differences() -> [Int] {
    var result: [Int] = []
    var previous: Int?
    for element in self {
      if let previous = previous {
        result.append(element - previous)
      }
      previous = element
    }

    return result
  }
}

func extraploateValues(_ values: [Int]) -> Int {
  if values.allSatisfy({ $0 == 0 }) {
    return 0
  }

  let differences = values.differences()

  let nextValue = extraploateValues(differences)
  // To get the value I need to solve this chart
  // 0   3   6   9  12  15  B
  //   3   3   3   3   3  A
  //     0   0   0   0  0

  // A = last of values + nextValue (0 + 3 = 3)
  // B = last of values + A (15 + 3 = 18)
  return nextValue + values.last!
}

let nextValues = values.map { extraploateValues($0) }

// Now I need to sum up all these values to understand the prediction of the report
let sum = nextValues.reduce(0, +)

print("The sum of the predictions is \(sum)")

// Okay, that doesn't tell me anything!
// I need more data to understand what I am seeing.

// Lets instead try to extrpolate the values backwards

func extraploateValuesBackwards(_ values: [Int]) -> Int {
  if values.allSatisfy({ $0 == 0 }) {
    return 0
  }

  let differences = values.differences()

  let prevValue = extraploateValuesBackwards(differences)
  // To get the value I need to solve this chart
  // D  10  13  16  21  30  45
  //   C   3   3   5   9  15
  //     B   0   2   4   6
  //       A   2   2   2
  //         0   0   0

  // A = first of values - nextValue (2 - 0 = 2)
  // B = first of values - A (0 - 2 = -2)
  // C = first of values - B (3 - -2 = 5)
  // D = first of values - C (10 - 5 = 5)
  return values.first! - prevValue
}

let prevValues = values.map { extraploateValuesBackwards($0) }
let sum2 = prevValues.reduce(0, +)

print("The sum of the backwards predictions is \(sum2)")
