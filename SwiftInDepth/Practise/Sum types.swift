//
//   Sum types.swift
//  SwiftInDepth
//
//  Created by Bakai on 9/3/23.
//

import Foundation

enum Day {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

enum Age {
    case known(UInt8)
    case unknown
}

enum PaymentType {
  case invoice
  case creditcard
  case cash
}

struct PaymentStatus {
  let paymentDate: Date?
  let isRecurring: Bool
  let paymentType: PaymentType
}

struct LearningPlan {
    
    var level: Int
    
    var description: String
    
    lazy private(set) var contents: String = {
        // Smart algorithm calculation simulated here
        print("I'm taking my sweet time to calculate.")
        sleep(2)
        
        switch level {
        case ..<25: return "Watch an English documentary."
        case ..<50: return "Translate a newspaper article to English and transcribe one song."
        case 100...: return "Read two academic papers and translate them into your native language."
        default: return "Try to read English for 30 minutes."
        }
    }()
}


//: Decodable allows you to turn raw data (such as plist files) into songs
struct Song: Decodable {
    let duration: Int
    let track: String
    let year: Int
}

struct Artist {

    var name: String
    var birthDate: Date
    var songsFileName: String

    init(name: String, birthDate: Date, songsFileName: String) {
        self.name = name
        self.birthDate = birthDate
        self.songsFileName = songsFileName
    }

    var age: Int? { // NOTE FY: This is automatically get-only property
        let years = Calendar.current
            .dateComponents([.year], from: Date(), to: birthDate)
            .day
        return years
    }

    lazy private(set) var songs: [Song] = { // NOTE FY: This can be set only by the owner, i.e within Artist
        guard
            let fileURL = Bundle.main.url(forResource: songsFileName, withExtension: "plist"),
            let data = try? Data(contentsOf: fileURL),
            let songs = try? PropertyListDecoder().decode([Song].self, from: data) else {
                return []
        }
        return songs
    }()

    
    mutating func songsReleasedAfter(year: Int) -> [Song] {
        return songs.filter { (song: Song) -> Bool in
            return song.year > year
        }
    }
}

var d = Artist(
    name: "Name is the same",
    birthDate: Date(),
    songsFileName: "Shape of you"
)

// var intensePlan = LearningPlan(level: 138, description: "A special plan for today!")
// intensePlan.contents
// var easyPlan = intensePlan
// easyPlan.level = 0
//
//  // Quiz: What does this print?
// print(easyPlan.contents)
