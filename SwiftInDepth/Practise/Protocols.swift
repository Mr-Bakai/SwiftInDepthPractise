//
//  Protocols.swift
//  SwiftInDepth
//
//  Created by Bakai on 13/3/23.
//

import Foundation

protocol CryptoCurrency {
    var name: String { get }
    var symbol: String { get }
    var holdings: Double { get set }
    var price: NSDecimalNumber? { get set }
}

/*
 VAR OR LET
 Whenever you declare properties on a protocol, they are always a var.
 The implementer can then choose to make it a let or var property.
 Also, if the protocol has a get set modifier on a property,
 the implementer has to offer a var to allow for mutation.
 */
struct Bitcoin: CryptoCurrency {
    let name = "Bitcoin"
    let symbol = "BTC"
    var holdings: Double
    var price: NSDecimalNumber?
    
    func calculateIt() -> Int {
        return 32
    }
}

struct Ethereum: CryptoCurrency {
    let name = "Ethereum"
    let symbol = "ETH"
    var holdings: Double
    var price: NSDecimalNumber?
}


// MARK: 8.1.2. Generics versus protocols

final class Portfolio<Coin: CryptoCurrency> {
    var coins: [Coin]
 
    init(coins: [Coin]) {
        self.coins = coins
    }

    func addCoin(_ newCoin: Coin) {
        coins.append(newCoin)
    }

    // ... snip. We are leaving out removing coins, calculating the total
    // value, and other functionality.
}


// MARK: 8.1.3. A trade-off with generics

/*
 There’s a shortcoming. The Coin generic represents a single type,
 so you can only add one type of coin to your portfolio.
 */

let coins = [
    Ethereum(holdings: 4, price: NSDecimalNumber(value: 500)),
    // If we mix coins, we can't pass them to Portfolio
    // Bitcoin(holdings: 4, price: NSDecimalNumber(value: 6000))
 ]
let portfolio = Portfolio(coins: coins)


/*
 Currently, the portfolio contains an Ethereum coin. Because you used a generic,
 Coin inside the portfolio is now pinned to Ethereum coins.
 Because of generics, if you add a different coin, such as Bitcoin,
 you’re stopped by the compiler, as shown in this listing.
 
 let btc = Bitcoin(holdings: 3, price: nil)
 portfolio.addCoin(btc)
 
 This would not work
 
 The compiler smacks you with an error. At compile time, the Portfolio
 initializer resolves the generic to Ethereum,
 which means that you can’t add different types to the portfolio.
 */



// MARK: 8.1.4. Moving to runtime

func Listing_8_7() {
    
    // Before
    final class PortfolioBase<Coin: CryptoCurrency> {
        var coins: [Coin] = []
        
        init(coins: [Coin]) {
            self.coins = coins
        }
    }

    // After
    final class Portfolio {
        var coins: [CryptoCurrency]
     
        init(coins: [CryptoCurrency]) {
            self.coins = coins
        }
    }
    
    // No need to specify what goes inside of portfolio.
    let portfolio = Portfolio(coins: [])
     
    // Now we can mix coins.
    let coins: [CryptoCurrency] = [
        Ethereum(holdings: 4, price: NSDecimalNumber(value: 500)),
        Bitcoin(holdings: 4, price: NSDecimalNumber(value: 6000))
    ]
    portfolio.coins = coins
    
}

/*
 Using a protocol at runtime means you can mix and match all sorts of types, which is a fantastic benefit.
 But the type you’re working with is a CryptoCurrency protocol. If Bitcoin has a special method called bitcoinStores(),
 you wouldn’t be able to access it from the portfolio unless the protocol has the method defined as well,
 which means all coins now have to implement this method.
 Alternatively, you could check at runtime if a coin is of a specific type,
 but that can be considered an anti-pattern and doesn’t scale with hundreds of possible coins.
 */


// MARK: Listing 8.10. A generic protocol vs. a runtime protocol

func retrievePriceRunTime(coin: CryptoCurrency, completion: ((CryptoCurrency) -> Void) ) {
     // ... snip. Server returns coin with most-recent price.
    var copy = coin
    copy.price = 6000
    completion(copy)
}

func retrievePriceCompileTime<Coin: CryptoCurrency>(coin: Coin, completion: ((Coin) -> Void)) {
     // ... snip. Server returns coin with most-recent price.
    var copy = coin
    copy.price = 6000
    completion(copy)
}

let btc = Bitcoin(holdings: 3, price: nil)

func justToShow() {
    
    retrievePriceRunTime(coin: btc) { (updatedCoin: CryptoCurrency) in
         print("Updated value runtime is \(updatedCoin.price?.doubleValue ?? 0)")
    }
    
    retrievePriceCompileTime(coin: btc) { (updatedCoin: Bitcoin) in
    print("Updated value compile time is \(updatedCoin.price?.doubleValue ?? 0)")
    }
}
