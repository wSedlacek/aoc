import Foundation

let path = "part2/question.txt"
let contents = try String(contentsOfFile: path, encoding: .utf8)

// Input format:
// Time:      7  15   30
// Distance:  9  40  200

// Longer input format:
// Time:        61     67     75     71
// Distance:   430   1036   1307   1150

let lines = contents.components(separatedBy: "\n")
var timeColumns = lines[0].trimmingCharacters(in: .whitespaces).components(separatedBy: "  ")
var distanceColumns = lines[1].trimmingCharacters(in: .whitespaces).components(separatedBy: "  ")

// Remove the "Time:" and "Distance:" headers
timeColumns.removeFirst()
distanceColumns.removeFirst()

// Remove empty spaces
timeColumns = timeColumns.filter { !$0.isEmpty }
distanceColumns = distanceColumns.filter { !$0.isEmpty }

// Trime whitespace
timeColumns = timeColumns.map { $0.trimmingCharacters(in: .whitespaces) }
distanceColumns = distanceColumns.map { $0.trimmingCharacters(in: .whitespaces) }

let times = timeColumns.map { Int($0) }
let distances = distanceColumns.map { Int($0) }

// Units are in milliseconds and millimeters
let races = zip(distances, times).map { distance, time in
  (totalRaceTime: time, distanceRecord: distance)
}

print("\(races)")

var allWaysToBeatRecord = 1
for race in races {
  // For each race I can spend time at the start of the race holding down the
  // button to charge up my speed. I increase in speed by 1 millimeter per
  // second for each millisecond of time the button is held. When I release the
  // button I travel at that speed until the end of the race.

  // If I hold down the button for 5 milliseconds, I'll be going 5 millimeters
  // but if the race is only 7 milliseconds long, I'll only travel 10 millimeters
  // in the remaining 2 milliseconds.

  // So the disntance I go is the multiplication of the time I hold down the
  // button and the time I travel at that speed. The length of time I can hold
  // added up with the remaining time is the total sum of the race time. So I
  // could hold for 1 millisecond and travel for 6 milliseconds or hold for 2
  // milliseconds and travel for 5 milliseconds.

  // I have a distance record I need to beat for each race. I need to figure out
  // how many different ways I can hold down the button to beat the record.

  // Maybe I can start at this record and finding the number of ways to beat it

  // Assume totalRaceTime and distanceRecord are optional Ints
  guard let totalRaceTime = race.totalRaceTime, totalRaceTime > 0 else {
    print("Invalid or missing total race time for race: \(race).")
    continue
  }

  guard let distanceRecord = race.distanceRecord else {
    print("Invalid or missing distance record for race: \(race).")
    continue
  }

  var waysToBeatRecord = 0

  for holdTime in 0...totalRaceTime {
    let speed = holdTime
    let travelTime = totalRaceTime - holdTime
    let distanceCovered = speed * travelTime

    if distanceCovered > distanceRecord {
      waysToBeatRecord += 1
    }
  }

  print("Ways to beat record: \(waysToBeatRecord)")
  allWaysToBeatRecord *= waysToBeatRecord
}

print("All ways to beat record: \(allWaysToBeatRecord)")
