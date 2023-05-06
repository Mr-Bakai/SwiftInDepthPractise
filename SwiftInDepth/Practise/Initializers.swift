//
//  Initializers.swift
//  SwiftInDepth
//
//  Created by Bakai on 12/3/23.
//

import Foundation

enum Pawn: CaseIterable {
    case dog, car, ketchupBottle, iron, shoe, hat
}

/*
 Under the hood, you get a so-called memberwise initializer,
 which is a free initializer the compiler generates for you, as shown here.
 */
struct Player {
  let name: String
  let pawn: Pawn
}

let player = Player(name: "SuperJeff", pawn: .shoe)


/*
 The struct needs all properties propagated with a value.
 If the struct initializes its properties, you don’t have to pass values.
 */
func listing_5_4() {
    
    struct Player {
        let name: String
        let pawn: Pawn

        init(name: String) {
            self.name = name
            self.pawn = Pawn.allCases.randomElement()!
         }
    }
    
    let player = Player(name: "SuperJeff")
    print(player.pawn) // shoe
}

/*
 It’s a useful protection mechanism! In your case,
 offering both the custom and memberwise initializers would be favorable.
 You can offer both initializers by extending the struct and putting your custom initializer there.
 */
extension Player {
    init(name: String) {
        self.name = name
        self.pawn = Pawn.allCases.randomElement()!
    }
}



// MARK: SUBCLUSSING

/*
 If you look inside BoardGame, you can confirm the use of one designated initializer
 and two convenience initializers, as shown here.
*/
class BoardGame {
    let players: [Player]
    let numberOfTiles: Int

    init(players: [Player], numberOfTiles: Int) {
        self.players = players
        self.numberOfTiles = numberOfTiles
    }
    
    convenience init(players: [Player]) {
        self.init(players: players, numberOfTiles: 32)
    }

    convenience init(names: [String]) {
        var players = [Player]()
        for name in names {
            players.append(Player(name: name))
        }
        self.init(players: players, numberOfTiles: 32)
    }
}

// Here are the different ways you can initialize the BoardGame superclass.
let boardGame = BoardGame(names: ["Melissa", "SuperJeff", "Dave"])

let players = [
    Player(name: "Melissa"),
    Player(name: "SuperJeff"),
    Player(name: "Dave")
]

//Convenience initializer
let boardGame2 = BoardGame(players: players)

//Designated initializer
let boardGame3 = BoardGame(players: players, numberOfTiles: 32)



// MARK: MutabilityLand
func listing_5_2_3_creatingSubclasses(){
    
    class MutabilityLand: BoardGame {
        var scoreBoard = [String: Int]()
        var winner: Player?
    }
    
    /*
     As shown in listing 5.10, you can initialize MutabilityLand the same way as
     BoardGame because it inherits all the initializers that BoardGame has to offer.
    */
    let mutabilityLand = MutabilityLand(names: ["Melissa", "SuperJeff", "Dave"])
    let mutabilityLand2 = MutabilityLand(players: players)
    let mutabilityLand3 = MutabilityLand(players: players, numberOfTiles: 32)
}


/*
 Since you override the superclass initializer, MutabilityLand needs to come up with its instructions there.
*/
class MutabilityLand: BoardGame {
    var scoreBoard = [String: Int]()
    var winner: Player?

    let instructions: String
    
    init(players: [Player], instructions: String, numberOfTiles: Int) {
        self.instructions = instructions
        super.init(players: players, numberOfTiles: numberOfTiles)
    }
    
    override init(players: [Player], numberOfTiles: Int) {
        self.instructions = "Read the manual"
        super.init(players: players, numberOfTiles: numberOfTiles)
    }
    
}

/*
 If you were to subclass MutabilityLand again and add a stored property,
 that subclass would have three initializers, and so on. At this rate, you’d have to
 override more initializers the more you subclass,
 making your hierarchy complicated. Luckily there is a solution to keep the
 number of designated initializers low so that each subclass holds only a single designated initializer.
 */

/*
 In the previous section, MutabilityLand was overriding the designated initializer from the BoardGame class.
 But a neat trick is to make the overridden initializer in MutabilityLand into
 a convenience override initializer (see figure 5.5).
 */

func listing_5_17() {
    
    class MutabilityLand: BoardGame {
        var scoreBoard = [String: Int]()
        var winner: Player?

        let instructions: String

        convenience override init(players: [Player], numberOfTiles: Int) {
            self.init(players: players, instructions: "Read the manual", numberOfTiles: numberOfTiles)
        }
        
        init(players: [Player], instructions: String, numberOfTiles: Int) {
            self.instructions = instructions
            super.init(players: players, numberOfTiles: numberOfTiles)
        }
        
    }
}

/*
 You can see how this sub-subclass only needs to override a single
 initializer to inherit all initializers. Out of good habit,
 this initializer is a convenience override as well, in case
 MutabilityLandJunior gets subclassed again, as shown in the following listing.
 */
class MutabilityLandJunior: MutabilityLand {
    let soundsEnabled: Bool

    init(soundsEnabled: Bool, players: [Player], instructions: String, numberOfTiles: Int) {
         self.soundsEnabled = soundsEnabled
         super.init(players: players, instructions: instructions, numberOfTiles: numberOfTiles)
    }

    convenience override init(players: [Player], instructions: String, numberOfTiles: Int) {
         self.init(soundsEnabled: false, players: players, instructions: instructions, numberOfTiles: numberOfTiles)
    }
}


/// You can now initialize this game in five ways.
let mutabilityLandJr = MutabilityLandJunior(
    players: players,
    instructions: "Kids don't read manuals",
    numberOfTiles: 8)

let mutabilityLandJr2 = MutabilityLandJunior(
    soundsEnabled: true,
    players:players,
    instructions: "Kids don't read manuals",
    numberOfTiles: 8)

//let mutabilityLandJr3 = MutabilityLandJunior(names: ["Philippe", "Alex"])

//let mutabilityLandJr4 = MutabilityLandJunior(players: players)

//let mutabilityLandJr5 = MutabilityLandJunior(players: players, numberOfTiles: 8)


