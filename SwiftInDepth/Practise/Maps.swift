//
//  Maps.swift
//  SwiftInDepth
//
//  Created by Bakai Ismaiilov on 23/6/24.
//

import Foundation

let commitStats = [
    (name: "Miranda", count: 30),
    (name: "Elly", count: 650),
    (name: "John", count: 0)
]

func mapFoo() {
    let readableStats = resolveCounts(statistics: commitStats)
    print(readableStats) // ["Miranda isn't very active on the project", "Elly is quite active", "John isn't involved in the project"]
}

func resolveCounts(statistics: [(String, Int)]) -> [String] {
    var resolvedCommits = [String]()
    for (name, count) in statistics {
        let involvement: String
        
        switch count {
        case 0: involvement = "\(name) isn't involved in the project"
        case 1..<100: involvement =  "\(name) isn't active on the project"
        default: involvement =  "\(name) is active on the project"
        }
        
        resolvedCommits.append(involvement)
    }
    return resolvedCommits
}

// same one but with a map
func resolveCountsMap(statistics: [(String, Int)]) -> [String] {
    return statistics.map { (name: String, count: Int) -> String in
         switch count {
         case 0: return "\(name) isn't involved in the project."
         case 1..<100: return "\(name) isn't very active on the project."
         default: return "\(name) is active on the project."
         }
    }
}

func counts(statistics: [(String, Int)]) -> [Int] {
    var counts = [Int]()
    for (name, count) in statistics where count > 0 {
        counts.append(count)
    }
    
    return counts.sorted(by: >)
}

// same one but elegantly
func countsMap(statistics: [(String, Int)]) -> [Int] {
    return statistics
        .map { $0.1 }
        .filter { $0 > 0 }
        .sorted(by: >)
}
