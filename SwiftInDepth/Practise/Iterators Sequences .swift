//
//  Iterators Sequences .swift
//  SwiftInDepth
//
//  Created by Bakai Ismaiilov on 10/11/23.
//

import Foundation
import UIKit

/// Whenever you use an `Array, String, stride, Dictionary`, and other types,
/// you’re working with something you can iterate over.
/// Iterators enable the use of for loops.
/// They also enable a large number of methods, including, but not limited to, `filter, map, sorted, and reduce`




// MARK: - 9.1.1. IteratorProtocol



/// Every time you use a for in loop, you’re using an iterator.
/// For example, you can loop over an array regularly via for in.

private func foo1() {
    let cheeses = ["Gouda", "Camembert", "Brie"]
    
    for cheese in cheeses {
        print(cheese)
    }
    
    // Output:
    //"Gouda"
    //"Camembert"
    //"Brie"
    
    
    
    
    
    
    /// But for in is syntactic sugar.
    /// Actually, what’s happening under the hood is that an iterator is created via the `makeIterator()` method.
    /// Swift walks through the elements via a while loop, shown here.
    /// Behind the scenes, Swift continuously calls `next()` on the iterator until it’s exhausted and ends the loop.
    
    var cheeseIterator = cheeses.makeIterator()
    while let cheese = cheeseIterator.next() {
         print(cheese)
    }

    // Output:
    //"Gouda"
    //"Camembert"
    //"Brie"
    
    
    
    
    /// Although a for loop calls `makeIterator()` under the hood, you can pass an iterator directly to a for loop:
    var cheeseIterator2 = cheeses.makeIterator()
    for element in cheeseIterator2 {
        print(element)
    }
    
    
    
    
    
    
    
    /// The `makeIterator()` method is defined in the `Sequence` protocol, 
    /// which is closely related to `IteratorProtocol`.
    /// Before moving on to `Sequence`, let’s take a closer look at `IteratorProtocol` first.
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - 9.1.2. The IteratorProtocol
    
    /// An `iterator` implements `IteratorProtocol`, which is a small, yet powerful component in Swift.
    /// IteratorProtocol has an associated type called `Element` and a `next()` method that returns an optional `Element`
    /// `Iterators generate values, which is how you can loop through multiple elements.`
    
    /// https://drek4537l1klr.cloudfront.net/veen/Figures/09fig01.jpg
    
    /*
     public protocol IteratorProtocol {
       /// The type of element traversed by the iterator.
       /// An Element associated type is defined,
       /// representing an element that an iterator product
     
       associatedtype Element

       mutating func next() -> Element?
     }
     */
    
    
    
    
    
    /// Every time you call next on an iterator,
    /// you get the next value an iterator produces until the iterator is exhausted, on which you receive nil.
    
    /// An iterator is like a bag of groceries— you can pull elements out of it, one by one.
    /// When the bag is empty, you’re out.
    /// The convention is that after an `iterator` depletes,
    /// it returns nil and any subsequen `next()` call is expected to return `nil, too, as shown in this example.
    
    let groceries = ["Flour", "Eggs", "Sugar"]
    var groceriesIterator: IndexingIterator<[String]> = groceries.makeIterator()
    print(groceriesIterator.next()!) // Optional("Flour")
    print(groceriesIterator.next()!) // Optional("Eggs")
    print(groceriesIterator.next()!) // Optional("Sugar")
    print(groceriesIterator.next()!) // nil
    print(groceriesIterator.next()!) // nil
    
}








// MARK: - 9.1.3. The Sequence protocol





/// Closely related to `IteratorProtocol`, the `Sequence` protocol is implemented all over Swift.
/// In fact, you’ve been using sequences all the time.
/// `Sequence` is the backbone behind any other type that you can iterate over.
/// `Sequence` is also the superprotocol of `Collection`,
/// which is inherited by `Array, Set, String, Dictionary`, and others, which means that these types also adhere to `Sequence`.


/// A `Sequence` can produce `iterators`.
/// Whereas an `IteratorProtocol` is exhaustive, after the elements inside an iterator are consumed, the iterator is depleted.
/// But that’s not a problem for `Sequence`, because `Sequence` can create a new `iterator` for a new loop.
/// This way, types conforming to `Sequence` can repeatedly be iterated over (see figure 9.2).
/// https://drek4537l1klr.cloudfront.net/veen/Figures/09fig02_alt.jpg



private protocol Sequence {
    
    /// An Element associated type is defined, representing an element that an iterator produces.
    associatedtype Element
    
    /// An associated type is defined and constrained to IteratorProtocol.
    associatedtype Iterator: IteratorProtocol where Iterator.Element == Element
    
    /// A Sequence can keep producing iterators.
    func makeIterator() -> Iterator
    
    /// Many methods are defined on Sequence, such as filter and forEach, to name a few.
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element]
    
    func forEach(_ body: (Element) throws -> Void) rethrows
}






/// To implement `Sequence`, you merely have to implement `makeIterator()`
/// Being able to produce `iterators` is the secret sauce to how a `Sequence` can be iterated over repeatedly, such as looping over an array multiple times.
/// `Sequence` may seem like an iterator factory, but don’t let this code snippet fool you.
/// `Sequence` packs quite the punch, because it offers many default methods,
/// such as `filter, map, reduce, flatMap, forEach, dropFirst, contains,` regular looping with `for in`, and much more.








// MARK: - 9.3. Creating a generic data structure with Sequence


/// First, let’s see how a bag works (see figure 9.4).
/// https://drek4537l1klr.cloudfront.net/veen/Figures/09fig05.jpg

/// You can insert objects just like `Set`, but with one big difference: `you can store the same object multiple times.`
/// Bag has one optimization trick up its sleeve, though,
/// because it keeps track of the number of times an object is stored and doesn’t physically store an object multiple times.
/// Storing an element only once keeps memory usage down.

struct Bag<Element: Hashable> {
    private var store = [Element: Int]()
 
    mutating func insert(_ element: Element) {
        store[element, default: 0] += 1
    }

    mutating func remove(_ element: Element) {
        store[element]? -= 1
        if store[element] == 0 {
             store[element] = nil
        }
    }

    var count: Int {
        return store.values.reduce(0, +)
    }

}














/// To help peek inside the bag, implement `CustomStringConvertible`
/// Whenever you print your bag, the `description` property supplies a custom
/// string of the elements inside and their occurrences, as shown in this listing.

extension Bag: CustomStringConvertible {
    var description: String {
        var summary = String()
        for (key, value) in store {
            let times = value == 1 ? "time" : "times"
            summary.append("\(key) occurs \(value) \(times)\n")
        }
        return summary
    }
}








private func foo4() {
//    let anotherBag: Bag = [1.0, 2.0, 2.0, 3.0, 3.0, 3.0]
//    print(ads)
    // Output:
    // 2.0 occurs 2 times
    // 1.0 occurs 1 time
    // 3.0 occurs 3 times
}




struct BagIterator<Element: Hashable>: IteratorProtocol {
    
    var store = [Element: Int]()
    
    mutating func next() -> Element? {
         guard let (key, value) = store.first else {
             return nil
         }
         if value > 1 {
             store[key]? -= 1
         } else {
             store[key] = nil
         }
         return key
     }
}


extension Bag: Sequence {
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        <#code#>
    }
    
    func forEach(_ body: (Element) throws -> Void) rethrows {
        
    }
    
    func makeIterator() -> BagIterator<Element> {
        return BagIterator(store: store)
    }
}
