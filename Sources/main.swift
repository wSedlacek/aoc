import Foundation

let path = "part2/puzzle.txt"
let contents = try String(contentsOfFile: path, encoding: .utf8)

// I have made it to metal island. It isn't what I expected though...
// Everything is cold and made of metal, and there is no sign of life.

// I see signposts pointing towards a hotsprint. There have been several
// and they all seem to point in the same direction. I guess I'll follow them...

// While I walk, I see something mechanical in my peripheral vision. I turn
// to look, but it scurries away jumping into a big pipe!

// It's fast! Very fast! And nothing like I've ever seen before. If I am going
// to get a chance to study it, I'll need to find a way to get ahead of it.

// As I look around I see that the entire ground is covered with pipes. It was
// hard to tell since they are all the same silver color as the metal ground.

// I made a drawing of the pipes.

// Legend:

// | is a vertical pipe connecting north and south.
// - is a horizontal pipe connecting east and west.
// L is a 90-degree bend connecting north and east.
// J is a 90-degree bend connecting north and west.
// 7 is a 90-degree bend connecting south and west.
// F is a 90-degree bend connecting south and east.
// . is ground; there is no pipe in this tile.
// S is the starting position of the animal; There is a pipe here. (could be any)

// Let's start by reading the map coordinates into a 2D array.

let map = contents.split(separator: "\n").map { $0.map { String($0) } }
print("Map:\n\(contents)")

// Next let's find the start position of the animal.

typealias Position = (x: Int, y: Int)
let start = map.enumerated().flatMap { (y, row) -> [Position] in
  return row.enumerated().compactMap { (x, tile) -> Position? in
    return tile == "S" ? (x, y) : nil
  }
}.first!

print("Start: \(start)")

// I can tell that whatever pipe the animal is in it is a loop.
// That is, it will eventually come back to the same position.
// There is 1 and only 1 loop that connects to the starting position.

// To get ahead of the animal, I need to find the position in the loop that is
// the furthest number of steps (regards of direction) from the starting
// position

// I can use the tortoise and hare algorithm to find the loop. From there I
// will have the length of the loop and can divide by 2 to find the middle of
// the loop to know where to go.

// Let's start by writing f(x). Since pipes connect two directions I will need
// to know what direction I am coming from.

enum Direction {
  case north
  case south
  case east
  case west
  case northEast
  case northWest
  case southWest
  case southEast

  func invert() -> Direction {
    switch self {
    case .north:
      return .south
    case .south:
      return .north
    case .east:
      return .west
    case .west:
      return .east
    case .northEast:
      return .southWest
    case .northWest:
      return .southEast
    case .southWest:
      return .northEast
    case .southEast:
      return .northWest

    }
  }

  func travel(from position: Position) -> Position {
    switch self {
    case .north:
      return (position.0, position.1 - 1)
    case .south:
      return (position.0, position.1 + 1)
    case .east:
      return (position.0 + 1, position.1)
    case .west:
      return (position.0 - 1, position.1)
    case .northEast:
      return (position.0 + 1, position.1 - 1)
    case .northWest:
      return (position.0 - 1, position.1 - 1)
    case .southWest:
      return (position.0 - 1, position.1 + 1)
    case .southEast:
      return (position.0 + 1, position.1 + 1)
    }
  }
}

enum Pipe {
  case northSouth
  case eastWest
  case northEast
  case northWest
  case southWest
  case southEast
  case wall
  case outside
  case squeeze

  func canTravel(from: Direction) -> Bool {
    switch self {
    case .northSouth:
      return from == .north || from == .south
    case .eastWest:
      return from == .east || from == .west
    case .northEast:
      return from == .south || from == .west
    case .northWest:
      return from == .south || from == .east
    case .southWest:
      return from == .north || from == .east
    case .southEast:
      return from == .north || from == .west
    case .squeeze:
      return true
    case .outside:
      return true
    default:
      return false
    }
  }

  func invert(direction: Direction) -> Direction {
    switch self {
    case .northSouth:
      return direction.invert()
    case .eastWest:
      return direction.invert()
    case .northEast:
      return direction == .north ? .east : .north
    case .northWest:
      return direction == .north ? .west : .north
    case .southWest:
      return direction == .south ? .west : .south
    case .southEast:
      return direction == .south ? .east : .south
    default:
      fatalError("Cannot invert direction for pipe: \(self)")
    }
  }

  static let northSouthDirections: [Direction] = [.north, .south]
  static let eastWestDirections: [Direction] = [.east, .west]
  static let northEastDirections: [Direction] = [.north, .east]
  static let northWestDirections: [Direction] = [.north, .west]
  static let southWestDirections: [Direction] = [.south, .west]
  static let southEastDirections: [Direction] = [.south, .east]
  static let defaultDirections: [Direction] = [
    .north, .south, .east, .west,
  ]

  func getFilledDirectionsDirections() -> [Direction] {
    switch self {
    case .northSouth:
      return Pipe.northSouthDirections
    case .eastWest:
      return Pipe.eastWestDirections
    case .northEast:
      return Pipe.northEastDirections
    case .northWest:
      return Pipe.northWestDirections
    case .southWest:
      return Pipe.southWestDirections
    case .southEast:
      return Pipe.southEastDirections
    case .outside, .squeeze, .wall:
      return Pipe.defaultDirections
    }
  }

  func directions() -> [Direction] {
    switch self {
    case .northSouth:
      return Pipe.northSouthDirections
    case .eastWest:
      return Pipe.eastWestDirections
    case .northEast:
      return Pipe.northEastDirections
    case .northWest:
      return Pipe.northWestDirections
    case .southWest:
      return Pipe.southWestDirections
    case .southEast:
      return Pipe.southEastDirections
    default:
      fatalError("Cannot get directions for pipe: \(self)")
    }
  }
}

func createMaze(startingPipe: Pipe) -> (Position, Direction) -> (
  to: Position, exitFrom: Direction, pipe: Pipe
)? {
  func getPipe(_ pipe: String) -> Pipe {
    switch pipe {
    case "|":
      return .northSouth
    case "-":
      return .eastWest
    case "L":
      return .northEast
    case "J":
      return .northWest
    case "7":
      return .southWest
    case "F":
      return .southEast
    case "S":
      return startingPipe
    case ".":
      return .wall
    default:
      fatalError("Unknown pipe type: \(pipe)")
    }
  }

  func getNextPipe(to: Position, exitFrom: Direction) -> Pipe? {
    // Check if the position is out of bounds
    guard to.x >= 0 && to.x < map[0].count && to.y >= 0 && to.y < map.count else {
      print("Out of bounds: \(to)")
      print("Map size: \(map[0].count)x\(map.count)")
      print("Map:\n\(contents)")

      if to.x < 0 {
        print("x < 0")
      }

      if to.x >= map[0].count {
        print("x >= \(map[0].count)")
      }

      if to.y < 0 {
        print("y < 0")
      }

      if to.y >= map.count {
        print("y >= \(map.count)")
        print("Line: \(map[to.y - 1])")
      }

      return nil
    }

    let nextPipe = getPipe(map[to.y][to.x])
    guard nextPipe.canTravel(from: exitFrom) else {
      return nil
    }

    return nextPipe
  }

  // Returns nil if pipe is a dead end
  func nextPosition(from: Position, enteredFrom: Direction) -> (
    to: Position, exitFrom: Direction, pipe: Pipe
  )? {
    let pipe = getPipe(map[from.y][from.x])
    let exitFrom = pipe.invert(direction: enteredFrom)
    let to = exitFrom.travel(from: from)

    guard let nextPipe = getNextPipe(to: to, exitFrom: exitFrom) else {
      return nil
    }

    return (to, exitFrom.invert(), nextPipe)
  }

  return nextPosition
}

// Since the starting position can be anytype of pipe I need to try each
// direction until I find a loop.

// I will loop through each direction and try to find a loop. If I find a loop

var loop: [[Pipe]] = map.map { row in
  return row.map { _ in Pipe.wall }
}

for pipe in [
  Pipe.northSouth,
  Pipe.eastWest,
  Pipe.northEast,
  Pipe.northWest,
  Pipe.southWest,
  Pipe.southEast,
] {
  let nextPosition = createMaze(startingPipe: pipe)

  var tortoise = (current: start, enteredFrom: pipe.directions()[0])
  var loopDetected = false
  var distance = 0

  print("---- Checking starting pipe: \(pipe)")
  while true {
    guard let tortoiseNext = nextPosition(tortoise.current, tortoise.enteredFrom)
    else {
      break
    }

    tortoise = (current: tortoiseNext.to, enteredFrom: tortoiseNext.exitFrom)
    distance += 1

    loop[tortoise.current.y][tortoise.current.x] = tortoiseNext.pipe
    if tortoise.current == start {
      print("Loop detected")
      loopDetected = true
      break
    }
  }

  if loopDetected {
    print("Loop length: \(distance)")
    print("Loop middle: \(distance / 2)")
    break
  }
}

func determinePipeBetween(current: Pipe, next: Pipe, horizontal: Bool) -> Pipe {

  if horizontal {
    // if current has `east` and next has `west` then it is a horizontal pipe
    if current.canTravel(from: .west) && next.canTravel(from: .east) {
      return .eastWest
    }

    return .squeeze
  } else {
    if current.canTravel(from: .north) && next.canTravel(from: .south) {
      return .northSouth
    }

    return .squeeze
  }
}

func exapandLoop(_ loop: [[Pipe]]) -> [[Pipe]] {
  // This doubles the size of the loop by adding blank spaces between each pipe
  // so that there is space to walk between each pipe.
  // The newly generated spaces are .squeeze as they are used to squeeze between pipes.
  // They are not counted in the loop length.

  let rowCount = loop.count
  guard rowCount > 0 else { return loop }

  let columnCount = loop[0].count
  guard columnCount > 0 else { return loop }

  var expandedLoop = Array(
    repeating: Array(repeating: Pipe.squeeze, count: columnCount * 2), count: rowCount * 2)

  // I will always be addint to the east and south of any pipes
  // so pipes that have connections east or south need a `|` or `-`
  // instead of a squeeze.

  // I will need to consider both the pipe to north and west of the current
  // pipe to determine if the current pipe needs a `|` or `-` instead of a
  // squeeze.

  for y in 0..<rowCount {
    for x in 0..<columnCount {
      // Original pipe position
      expandedLoop[y * 2][x * 2] = loop[y][x]

      // Add to the east (right) of the pipe
      if x < columnCount - 1 {
        expandedLoop[y * 2][x * 2 + 1] = determinePipeBetween(
          current: loop[y][x], next: loop[y][x + 1], horizontal: true)
      }

      // Add to the south (bottom) of the pipe
      if y < rowCount - 1 {
        expandedLoop[y * 2 + 1][x * 2] = determinePipeBetween(
          current: loop[y][x], next: loop[y + 1][x], horizontal: false)
      }

      // Handle the southeast diagonal position
      if x < columnCount - 1 && y < rowCount - 1 {
        expandedLoop[y * 2 + 1][x * 2 + 1] = .squeeze  // Adjust this based on your diagonal rules
      }
    }
  }

  return expandedLoop

}

func printLoop(_ loop: [[Pipe]]) {
  print("Loop:")
  for row in loop {
    print(
      row.map { pipe in
        switch pipe {
        case .northSouth:
          return "|"
        case .eastWest:
          return "-"
        case .northEast:
          return "L"
        case .northWest:
          return "J"
        case .southWest:
          return "7"
        case .southEast:
          return "F"
        case .outside:
          return "."
        case .wall:
          return "#"
        case .squeeze:
          return " "
        }
      }.joined())
  }
}

printLoop(loop)
func floodFill(loop: inout [[Pipe]], position: Position) {
  func _floodFill(_ position: Position) {
    guard
      position.x >= 0 && position.x < loop[0].count && position.y >= 0 && position.y < loop.count
    else {
      return
    }

    guard loop[position.y][position.x] != .outside else {
      return
    }

    let pipe = loop[position.y][position.x]
    let directions = pipe.getFilledDirectionsDirections()

    loop[position.y][position.x] = .outside

    for direction in directions {
      _floodFill(direction.travel(from: position))
    }
  }

  _floodFill(position)
}

func edgePositions(in grid: [[Pipe]]) -> [Position] {
  var edgePositions = [Position]()

  let rowCount = grid.count
  guard rowCount > 0 else { return edgePositions }

  let columnCount = grid[0].count
  guard columnCount > 0 else { return edgePositions }

  // Top and bottom rows
  for x in 0..<columnCount {
    edgePositions.append((x, 0))
    edgePositions.append((x, rowCount - 1))
  }

  for y in 1..<(rowCount - 1) {
    edgePositions.append((0, y))
    edgePositions.append((columnCount - 1, y))
  }

  return edgePositions
}

var expandedLoop = exapandLoop(loop)
let edges = edgePositions(in: expandedLoop)
for edge in edges {
  floodFill(loop: &expandedLoop, position: edge)
}

printLoop(expandedLoop)

// extract remaining walls
let walls = expandedLoop.enumerated().flatMap { (y, row) -> [Position] in
  return row.enumerated().compactMap { (x, tile) -> Position? in
    return tile == .wall ? (x, y) : nil
  }
}

print("Enclosed Spaces: \(walls.count)")
