import Foundation

// Camel Cards! - Poker, but easier to play while riding camels.

// Possible cards are: A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, or 2.
// A is the highest and 2 is the lowest.

// We eed an enum that is comparable for each card label

enum CardLabel: String, Comparable {
  case A = "A"
  case K = "K"
  case Q = "Q"
  case J = "J"
  case T = "T"
  case nine = "9"
  case eight = "8"
  case seven = "7"
  case six = "6"
  case five = "5"
  case four = "4"
  case three = "3"
  case two = "2"

  // J is wild (joker) but also the lowest card
  static let order = [A, K, Q, T, nine, eight, seven, six, five, four, three, two, J]

  static func < (lhs: CardLabel, rhs: CardLabel) -> Bool {
    return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
  }
}

// Possible hands: (Strongest to weakest)
// - Five of a kind (all the same label)
// - Four of a kind (4 of the same label)
// - Full house (3 of one label, 2 of another)
// - Three of a kind (3 of the same label)
// - Two pair (two of one label, two of another label)
// - One pair (two of the same label)
// - High card (all cards have different labels)

// We need an enum that is comparable for each hand type
enum HandType: Int, Comparable {
  case fiveOfAKind = 1
  case fourOfAKind = 2
  case fullHouse = 3
  case threeOfAKind = 4
  case twoPair = 5
  case onePair = 6
  case highCard = 7

  static func < (lhs: HandType, rhs: HandType) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

// Hands have two ordering rules.
// Primary - Strongest to wekaest hand type
// Fallback (for equal hands) - Label from left to right highest to lowest
// - 33332 is higher than 2AAAA
// - 77888 is higher than 77788

// Sequences of cards should also be comparable
extension Sequence where Element == CardLabel {
  static func < (lhs: Self, rhs: Self) -> Bool {
    // Compared left to right until we find a difference
    for (left, right) in zip(lhs, rhs) {
      if left != right {
        return left < right
      }
    }

    // If we get here, all the cards are the same
    return false
  }
}

// We will get X hands as input. Along with each hand we will get a bid amount
// for that hand. Each hand is ranked by it's order, so the lowest hand is
// ranked 1, the next is 2, etc. The highest hand is ranked X. The bid amount
// for each hand is multiplied by the rank of that hand. The total winnings
// are the sum of the winnings for each hand.

// We need a hand that is comparable based off it's hand type and card labels
// It should identify the hand type by the cards in the hand

struct Hand: Comparable {
  let cards: [CardLabel]
  let bid: Int
  let type: HandType

  init(cards: [CardLabel], bid: Int) {
    self.cards = cards
    self.bid = bid
    self.type = Hand.determineHandType(cards: cards)
  }

  static func < (lhs: Hand, rhs: Hand) -> Bool {
    if lhs.type == rhs.type {
      return lhs.cards < rhs.cards
    }

    return lhs.type < rhs.type
  }

  static func determineHandType(cards: [CardLabel]) -> HandType {
    let labels = cards.map { $0.rawValue }
    let wildCardCount = labels.filter { $0 == "J" }.count
    let nonWildCards = labels.filter { $0 != "J" }
    let labelSet = Set(nonWildCards)
    var labelCounts = labelSet.map { label in
      return nonWildCards.filter { $0 == label }.count
    }

    // Distribute wild cards to form the best hand
    if wildCardCount > 0 {
      for _ in 1...wildCardCount {
        if let maxIndex = labelCounts.indices.max(by: { labelCounts[$0] < labelCounts[$1] }) {
          labelCounts[maxIndex] += 1
        } else {
          // If there are no non-wild cards, treat each wild card as a separate rank
          labelCounts.append(1)
        }
      }
    }

    let sortedCounts = labelCounts.sorted(by: >)

    switch sortedCounts {
    case [5]:
      return .fiveOfAKind
    case [4, 1]:
      return .fourOfAKind
    case [3, 2]:
      return .fullHouse
    case [3, 1, 1]:
      return .threeOfAKind
    case [2, 2, 1]:
      return .twoPair
    case [2, 1, 1, 1]:
      return .onePair
    default:
      return .highCard
    }
  }
}

// Hands should be printable including their cards, type and bid
extension Hand: CustomStringConvertible {
  var description: String {
    let cardString = cards.map { $0.rawValue }.joined(separator: "")
    return "Cards: \(cardString), Type: \(type), Bid: \(bid)"
  }
}

// --- Game logic

let path = "part2/question.txt"
let contents = try String(contentsOfFile: path, encoding: .utf8)

// Each line is a hand followed by a bind amount in this format
// 32T3K 765
// T55J5 684
// KK677 28
// KTJJT 220
// QQQJA 483

// Go through each line and extract the strings
let lines = contents.split(separator: "\n")
let hands = lines.map { line -> Hand in
  let parts = line.split(separator: " ")
  let cards = parts[0].map { CardLabel(rawValue: String($0))! }
  let bid = Int(parts[1])!
  return Hand(cards: cards, bid: bid)
}

// Sort the hands by their rank
let sortedHands = hands.sorted()

// Print hands on each line
sortedHands.forEach { print($0) }

// Calculate the winnings
let winnings = sortedHands.enumerated().map { (index, hand) -> Int in
  return hand.bid * (sortedHands.count - index)
}.reduce(0, +)

print("Winnings: \(winnings)")
