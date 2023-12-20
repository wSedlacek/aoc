import Foundation

let path = "part2/question.txt"
let contents = try String(contentsOfFile: path, encoding: .utf8)
let lines = contents.components(separatedBy: "\n").dropLast()

// I am lost in a desert! But I have a map! The only problem is that it isn't
// your typical map. The first line of the map is a list of left and right
// instructions. In order to stay safe I HAVE to follow these instructions
// exactly.

// Each isntruction is exactly 1 letter of either L or R in a row like LLRLRL
// THEY AREN'T SEPARATED BY ANYTHING!

let instructions = lines[0].map { String($0) }

// The sequence goes on forever or at least until I reach the end.
// In swift I can use a sequence to represent this.

let instructionSequence = AnySequence<String> {
  var index = 0
  return AnyIterator<String> {
    if index >= instructions.count {
      index = 0
    }

    let next = instructions[index]
    index += 1
    return next
  }
}

// The next part is a table of locations and destinations on the left and right
// of that location. For example AAA is a location and it has destiionations of
// (BBB and CCC). Following the instructions I will proceed to the next
// location.

// Each line starting on the 3rd line looks like AAA = (BBB, CCC)

let locations = lines[2..<lines.count].reduce(into: [String: (String, String)]()) { table, line in
  let parts = line.components(separatedBy: " = ")
  let location = parts[0]

  // I need to remove the ( and the ) from the destinations
  let destinations = parts[1].dropFirst().dropLast().components(separatedBy: ", ")
  table[location] = (destinations[0], destinations[1])
}

// My goal is to find ZZZ as it must be the way out of this haunted desert.
// But, if I reach the end of the instructions I might not be at ZZZ. If this
// is the case I must repeat the instructions until I reach ZZZ.

// To make this map better for the next person I will keep track of how many
// instructions I have followed to get from AAA to ZZZ.

func part1() {
  var currentLocation = "AAA"
  var instructionsFollowed = 0

  for instruction in instructionSequence {
    let (left, right) = locations[currentLocation]!
    if instruction == "L" {
      currentLocation = left
    } else {
      currentLocation = right
    }

    instructionsFollowed += 1

    if currentLocation == "ZZZ" {
      break
    }
  }

  // I have finally reached ZZZ! I am free!
  print("I followed \(instructionsFollowed) instructions to get to ZZZ")
}

// Wait a minute! I am not free! I am in a loop! I am just back to whare I started!

// Looking closer at the map the nodes aren't just AAA they are 11A and 22A
// etc. Since this destert is haunted this map must be for GHOST! Since
// everyone knows ghost can be in more than once place at once. I have to think
// like that if I am ever going to escape.

// Lets tart by figuring out all the places I am at once. Every place that ends
// with `A is a place I am at.

var places = locations.keys.filter { $0.hasSuffix("A") }

func part2Forever() {
  var instructionsFollowed = 0

  // Next I need to follow the instrucrtions updating ALL the places I am at.

  for instruction in instructionSequence {
    places = places.map { location in
      let (left, right) = locations[location]!
      if instruction == "L" {
        return left
      } else {
        return right
      }
    }

    instructionsFollowed += 1
    if places.allSatisfy({ $0.hasSuffix("Z") }) {
      // I am only free if EVERY place I am ends in Z
      // EXCEPT, this takes FOREVER. I will never get out of here.
      // How can I figure this out faster?
      break
    }
  }

  // Now I am really free! No ghost desert can hold me! Now to write the
  // instructions on the map so no one else gets lost.

  print("I followed \(instructionsFollowed) instructions to get to get EVERY place to end in Z")
}

// Since that strategy takes forever I need to figure out a better way.
// I can't simply follow the instructions as written.
// I could try to work backwards, but I would end up with a sequence of the same length so it will also take forever.

// I need to think about this in a different way.

// Let's try approaching this mathmaticly.
// I can find the cycle length of each starting point and then I can find the LCM of the cycle lengths.

func findCycleLength(startingPoint: String, locations: [String: (String, String)]) -> Int {
  var currentLocation = startingPoint
  var instrunctionCount = 0

  for instrunction in instructionSequence {
    let (left, right) = locations[currentLocation]!
    if instrunction == "L" {
      currentLocation = left
    } else {
      currentLocation = right
    }

    instrunctionCount += 1
    if currentLocation.hasSuffix("Z") {
      break
    }
  }

  return instrunctionCount
}

func lcm(_ a: Int, _ b: Int) -> Int {
  return a / gcd(a, b) * b
}

func gcd(_ a: Int, _ b: Int) -> Int {
  var a = a
  var b = b
  while b != 0 {
    let t = b
    b = a % b
    a = t
  }
  return a
}

extension Sequence where Element == Int {
  func greatestCommonDivisor() -> Int? {
    let numbers = Array(self)
    guard let first = numbers.first else { return nil }

    return numbers.dropFirst().reduce(first) { gcd($0, $1) }
  }

  func leastCommonMultiple() -> Int? {
    let numbers = Array(self)
    guard let first = numbers.first else { return nil }

    return numbers.dropFirst().reduce(first) { lcm($0, $1) }
  }
}

let cycleLengths = places.map { findCycleLength(startingPoint: $0, locations: locations) }
let stepsToEscape = cycleLengths.leastCommonMultiple()!

print("Steps to escape: \(stepsToEscape)")
print("HOW MANY?! God this is gonna take forever. Better get started!")
