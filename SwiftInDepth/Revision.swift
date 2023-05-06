//
//  Revision.swift
//  SwiftInDepth
//
//  Created by Bakai on 8/4/23.
//

import Foundation

protocol CryptoCurrencyR {
    var name: String { get }
    var symbol: String { get }
    var holdings: Double { get set }
    var price: NSDecimalNumber { get set }
}

struct BitCoinR: CryptoCurrencyR {
    var name: String = "Bitcoin"
    var symbol: String = "BTC"
    var holdings: Double
    var price: NSDecimalNumber
}

struct EthereumR: CryptoCurrencyR {
    var name: String = "Ethereum"
    var symbol: String = "ETH"
    var holdings: Double
    var price: NSDecimalNumber
}


final class PortfolioR<Coin: CryptoCurrencyR> {
    var coins: [Coin]
    
    init(coins: [Coin]) {
        self.coins = coins
    }
    
    func addCoin(_ newCoin: Coin) {
        self.coins.append(newCoin)
    }
}
