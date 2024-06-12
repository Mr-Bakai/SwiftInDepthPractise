//
//  Generics.swift
//  SwiftInDepth
//
//  Created by Bakai on 11/3/23.
//

import Foundation


// Nongeneric version
func firstLast(array: [Int]) -> (Int, Int) {
    return (array[0], array[array.count-1])
}

// Generic version
func firstLast<T>(array: [T]) -> (T, T) {
    return (array[0], array[array.count-1])
}


func firstLastl<T>(array: [T]) -> (T, T) {
    
    let first: T = array[0]
    let second: T = array[array.count - 1]
    
    return (first, second)
}


let (frist, second) = firstLast(array: ["This", "Is", "The one"])
let (first, second2) = firstLast(array: [10, 20 ,30])

//Listing 7.6. Custom types can be passed to Generic funcs too

struct Waffle {
    let size: String
}


let (firstWaffle, secondWaffle) = firstLast(array: [
    Waffle(size: "1"),
    Waffle(size: "2"),
    Waffle(size: "3")
])


func wrapValue<T>(value: T) -> [T] {
    return [value]
}


func wrap<T>(value: Int, secondValue: T) -> ([Int], T) {
    return ([value], secondValue)
}

func wrap<T>(value: Int, secondValue: T) -> ([Int], Int)? {
    if let secondValue = secondValue as? Int {
        return ([value], secondValue)
    } else {
        return nil
    }
}


func lowest<T: Comparable>(_ array: [T]) -> T? {
    let sortedArray = array.sorted { (lhs, rhs) -> Bool in
        return lhs < rhs
    }
    return sortedArray.first
}


func foo() {
    lowest([1,2,3])
}


//Listing 7.17. The RoyalRank enum, adhering to Comparable?
enum RoyalRank: Comparable {
    case emperor
    case king
    case duke
    
    static func <(lhs: RoyalRank, rhs: RoyalRank) -> Bool {
        switch (lhs, rhs) {
        case (king, emperor): return true
        case (duke, emperor): return true
        case (duke, king): return true
        default: return false
        }
    }
}


/*
 If a generic signature gets a bit hard to read, you can use a where clause,
 as an alternative, which goes at the end of a function, as shown here.
 */

//func lowestOccurrences<T>(values: [T]) -> [T: Int] where T: Comparable & Hashable {
//    // ... snip
//    return [T:0]
//}

//Creating a generic type

public enum Optional<Wrapped> {
  case none
  case some(Wrapped)
}


struct Pair<T: Hashable, U: Hashable>: Hashable {
    
    private let left: T
    private let right: U
    
    init(_ left: T, _ right: U) {
        self.left = left
        self.right = right
    }
}


let pair = Pair<Int, Int>(10, 10)

func foo2(){
    print(pair.hashValue)
}
