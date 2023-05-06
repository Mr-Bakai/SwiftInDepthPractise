//
//  BoardGame.swift
//  SwiftInDepth
//
//  Created by Bakai on 13/3/23.
//

import Foundation

//Adding the required keyword to initializers
func listing_5_23() {
    
    class BoardGame {
        let players: [Player]
        let numberOfTiles: Int
        
        class func makeGame(players: [Player]) -> Self {
            let boardGame = self.init(players: players, numberOfTiles: 32)
            // Configuration goes here.
            // E.g.
            // boardGame.locale = Locale.current
            // boardGame.timeLimit = 900
            return boardGame
        }

        required init(players: [Player], numberOfTiles: Int) {
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
    
    class MutabilityLand: BoardGame {
        var scoreBoard = [String: Int]()
        var winner: Player?

        let instructions: String

        convenience required init(players: [Player], numberOfTiles: Int) {
            self.init(players: players, instructions: "Read the manual", numberOfTiles: numberOfTiles)
        }
        
        init(players: [Player], instructions: String, numberOfTiles: Int) {
            self.instructions = instructions
            super.init(players: players, numberOfTiles: numberOfTiles)
        }
    }
    
    
    let boardGame = BoardGame.makeGame(players: players)
    let mutabilityLand = MutabilityLand.makeGame(players: players)
}


// MARK: BoardGame and Protocol (required)
protocol BoardGameType {
    init(players: [Player], numberOfTiles: Int)
}

class BoardGameP: BoardGameType {
    required init(players: [Player], numberOfTiles: Int) {}
}



/*
 If a class is final, you can drop any required keywords from the initializers.
 For example, let’s say nobody likes playing the games that are subclassed, except for the BoardGame itself.
 Now you can make BoardGame final and delete any subclasses.
 Note that you’re omitting the required keyword from the designated initializer.
 */

func listing_5_27() {
    final class BoardGame: BoardGameType {
        let players: [Player]
        let numberOfTiles: Int

        // No need to make this required
        init(players: [Player], numberOfTiles: Int) {
            self.players = players
            self.numberOfTiles = numberOfTiles
        }

        class func makeGame(players: [Player]) -> Self {
            return self.init(players: players, numberOfTiles: 32)
        }
        // ... snip
    }
    
}
