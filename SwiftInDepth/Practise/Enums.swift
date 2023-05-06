//
//  Enums.swift
//  SwiftInDepth
//
//  Created by Bakai on 6/5/23.
//

import Foundation

struct Message {
    let userId: String
    let contents: String?
    let date: Date

    let hasJoined: Bool
    let hasLeft: Bool

    let isBeingDrafted: Bool
    let isSendingBalloons: Bool
}

let joinMessage = Message(userId: "1",
                          contents: nil,
                          date: Date(),
                          hasJoined: true, // Set the joined Boolean
                          hasLeft: false,
                          isBeingDrafted: false,
                          isSendingBalloons: false)


let textMessage = Message(userId: "2",
                          contents: "Hey everyone!", // Pass a message
                          date: Date(),
                          hasJoined: false,
                          hasLeft: false,
                          isBeingDrafted: false,
                          isSendingBalloons: false)


/*
 An invalid message state doesn’t bode well because a message can only be
 one or another in the business rules of the application.
 The visuals won’t support an invalid message either.
 
 To illustrate, you can have a message in an invalid state.
 It represents a text message, but also a join and a leave message. 👇🏻
 */

let brokenMessage = Message(userId: "1",
                          contents: "Hi there", // Have text to show
                          date: Date(),
                          hasJoined: true, // But this message also signalsa joining state
                          hasLeft: true, // ... and a leaving state
                          isBeingDrafted: false,
                          isSendingBalloons: false)


/*
 Imagine parsing a local file to a Message, or some function
 that combines two messages into one.
 You don’t have any compile-time guarantees that a message is in the right state 👆🏻.
 */


enum MessageEnum {
    case text(userId: String, contents: String, date: Date)
    case draft(userId: String, date: Date)
    case join(userId: String, date: Date)
    case leave(userId: String, date: Date)
    case balloon(userId: String, date: Date)
}

let textMessageEnum = MessageEnum.text(userId: "2", contents: "Bonjour!", date: Date())
let joinMessageEnum = MessageEnum.join(userId: "2", date: Date())

/* 👆🏻
 Whenever you want to create a Message as an enum, you can pick
 the proper case with related properties, without worrying about
 mixing and matching the wrong values.
 */


// logMessage(message: joinMessageEnum)
// logMessage(message: textMessageEnum)

func logMessage(message: MessageEnum) {
    switch message {
    case let .text(userId: id, contents: contents, date: date):
        print("[\(date)] User \(id) sends message: \(contents)")
    case let .draft(userId: id, date: date):
        print("[\(date)] User \(id) is drafting a message")
    case let .join(userId: id, date: date):
        print("[\(date)] User \(id) has joined the chatroom")
    case let .leave(userId: id, date: date):
        print("[\(date)] User \(id) has left the chatroom")
    case let .balloon(userId: id, date: date):
        print("[\(date)] User \(id) is sending balloons")
    }
}


 
struct Run {
    let id: String
    let startTime: Date
    let endTime: Date
    let distance: Float
    let onRunningTrack: Bool
}

struct Cycle {

    enum CycleType {
        case regular
        case mountainBike
        case racetrack
    }
    let id: String
    let startTime: Date
    let endTime: Date
    let distance: Float
    let incline: Int
    let type: CycleType
}

struct Pushups {
    let repetitions: [Int]
    let date: Date
}



enum Workout {
    case run(Run)
    case cycle(Cycle)
    case pushups(Pushups)
}


let pushups = Pushups(repetitions: [22,20,10], date: Date())
let workout = Workout.pushups(pushups)


private func switchWorkout() {
    switch workout {
    case .run(let run):
        print("Run: \(run)")
    case .cycle(let cycle):
        print("Cycle: \(cycle)")
    case .pushups(let pushups):
        print("Pushups: \(pushups)")
    }
}


// MARK: - String matching

enum ImageType: String {
    case jpg
    case bmp
    case gif

    init?(rawValue: String) { // NOTE FY
        switch rawValue.lowercased() {
        case "jpg", "jpeg": self = .jpg
        case "bmp", "bitmap": self = .bmp
        case "gif", "gifv": self = .gif
        default: return nil
        }
    }
}

