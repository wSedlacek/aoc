import Foundation

extension Array {
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}

let path = "part1/question.txt"
let contents = try String(contentsOfFile: path, encoding: .utf8)
let blocks = contents.components(separatedBy: "\n\n").map {
  $0.trimmingCharacters(in: .whitespacesAndNewlines)
}

let seeds = blocks[0]
  .replacingOccurrences(of: "seeds: ", with: "")
  .components(separatedBy: " ")
  .map { Int($0)! }
let seedRanges = seeds.chunked(into: 2).map { (seed_start: $0[0], seed_end: $0[0] + $0[1]) }

typealias Rule = (destinationRangeStart: Int, sourceRangeStart: Int, rangeLength: Int)

let almanac: [[Rule]] = blocks[1...].map { block in
  let lines = block.components(separatedBy: "\n")
  return lines[1...].map { line in
    let components = line.components(separatedBy: " ").compactMap(Int.init)

    return (
      destinationRangeStart: components[0],
      sourceRangeStart: components[1],
      rangeLength: components[2]
    )
  }
}

let reversedAlmanac = Array(almanac.reversed())

@inline(__always)
func applyRule(rule: Rule, location: Int) -> Int? {
  if rule.sourceRangeStart <= location && rule.sourceRangeStart + rule.rangeLength > location {
    return rule.destinationRangeStart + (location - rule.sourceRangeStart)
  }

  return nil
}

@inline(__always)
func inverseRule(rule: Rule, possibleSeed: Int) -> Int? {
  if rule.destinationRangeStart <= possibleSeed
    && rule.destinationRangeStart + rule.rangeLength > possibleSeed
  {
    return rule.sourceRangeStart + (possibleSeed - rule.destinationRangeStart)
  }

  return nil
}

/// This just processes the rules as writte, each seed goes through the rules
/// to get it's location then they are all passed through a min

func followSeeds() -> Int {
  let locations = seeds.map { seed in
    let location = almanac.reduce(seed) { (location, rules) in
      for rule in rules {
        if let newLocation = applyRule(rule: rule, location: location) {
          return newLocation
        }
      }

      return location
    }

    return location
  }

  let lowestLocation = locations.min()!
  return lowestLocation
}

/// This uses a revers lookup where we start with a possible location then
/// process it backwards to see if it is a range of seeds.

@inline(__always)
func checkLocation(possibleLocation: Int) -> Bool {

  // while loop is faster than reduce and for-in (required for processing this much data)
  var possibleSeed = possibleLocation
  var almanacIndex = 0
  while almanacIndex < reversedAlmanac.count {
    let rules = reversedAlmanac[almanacIndex]

    var ruleIndex = 0
    while ruleIndex < rules.count {
      if let newLocation = inverseRule(rule: rules[ruleIndex], possibleSeed: possibleSeed) {
        possibleSeed = newLocation
        break
      }

      ruleIndex += 1
    }

    almanacIndex += 1
  }

  return seedRanges.contains(where: {
    return possibleSeed >= $0.seed_start && possibleSeed <= $0.seed_end
  })
}

func checkAllLocations(start: Int = 0) -> Int? {
  var lowestLocation: Int? = nil
  var posibleLocation = start

  while true {
    if checkLocation(possibleLocation: posibleLocation) {
      lowestLocation = posibleLocation
      break
    }

    if posibleLocation % 100000 == 0 {
      print("checked \(posibleLocation)")
    }

    posibleLocation += 1
  }

  return lowestLocation
}

// let lowestLocation = followSeeds()
let lowestLocation = checkAllLocations()
print("lowest location: \(lowestLocation!)")
