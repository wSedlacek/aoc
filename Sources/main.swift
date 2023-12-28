import Foundation

let path = "part2/puzzle.txt"
let contents = try String(contentsOfFile: path, encoding: .utf8)

// I am now at an observatory. Here I need to help the elves with the research.
// We have a universe as a grid. `.` is an empty space, `#` is a galaxy.

typealias Universe = [[Character]]
let universe: Universe = contents.split(separator: "\n").map { Array($0) }

enum Rotation {
  case clockwise
  case counterClockwise
}

func rotateUniverse(_ universe: Universe, rotation: Rotation) -> Universe {
  var rotatedUniverse: Universe = Array(repeating: [], count: universe[0].count)

  for row in universe {
    for (index, column) in row.enumerated() {
      rotatedUniverse[index].append(column)
    }
  }

  if rotation == .clockwise {
    rotatedUniverse = rotatedUniverse.map { Array($0.reversed()) }
  } else {
    rotatedUniverse = rotatedUniverse.reversed()
  }

  return rotatedUniverse
}

print("Finding galaxies... 🚀")
// Okay the universe is bigger, now I need to determine all the galaxies.
typealias Galaxy = (x: Int, y: Int)

var galaxies: [Galaxy] = []
for (y, row) in universe.enumerated() {
  for (x, column) in row.enumerated() {
    if column == "#" {
      galaxies.append((x, y))
    }
  }
}

print("Found \(galaxies.count) galaxies.")

// Okay now I need to know how many steps (only going up, down, left and
// right) it takes to get from any galaxy to any other galaxy.

// get all combinations of galaxies where from->to is the same as to->from
var galaxyCombinations: [(from: Galaxy, to: Galaxy)] = []

// I need to avoid adding duplicates of the same pairs.
// I can do this by only adding pairs where the first galaxy is smaller than
// the second galaxy.

for (index, galaxy) in galaxies.enumerated() {
  for (index2, galaxy2) in galaxies.enumerated() {
    if index >= index2 {
      continue
    }

    galaxyCombinations.append((galaxy, galaxy2))
  }
}

print("Found \(galaxyCombinations.count) galaxy combinations.")

let universeAge = 1_000_000

func findSteps(from: Galaxy, to: Galaxy) -> Int {
  var steps = 0

  var currentPosition = from
  while currentPosition != to {

    if currentPosition.x < to.x {
      currentPosition.x += 1
    } else if currentPosition.x > to.x {
      currentPosition.x -= 1
    } else if currentPosition.y < to.y {
      currentPosition.y += 1
    } else if currentPosition.y > to.y {
      currentPosition.y -= 1
    }

    let isEmptyRow = universe[currentPosition.y].allSatisfy { $0 == "." }
    let isEmptyColumn = universe.allSatisfy { $0[currentPosition.x] == "." }
    let isEmptySpace = isEmptyRow || isEmptyColumn
    steps += isEmptySpace ? universeAge : 1
  }

  return steps
}

print("Finding steps... 🚀")

let steps = galaxyCombinations.map { findSteps(from: $0.from, to: $0.to) }

print("The shortest path is \(steps.min()!) steps long.")
print("The longest path is \(steps.max()!) steps long.")
print("The sum of all paths is \(steps.reduce(0, +)) steps long.")
