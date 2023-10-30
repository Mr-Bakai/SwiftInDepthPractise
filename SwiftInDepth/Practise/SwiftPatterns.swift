//
//  SwiftPatterns.swift
//  SwiftInDepth
//
//  Created by Bakai Ismaiilov on 17/10/23.
//

import Foundation
import XCTest

extension URLSessionDataTask: DataTask {}
extension URLSession: Session {}



/// URLSessionDataTask has a resume() method, but Session.Task does not.
/// To fix this, you introduce a new protocol called DataTask, which contains the resume() method.
/// Then you constrain Session.Task to DataTask.

protocol DataTask {
    func resume()
}


enum ApiError: Error {
     case couldNotLoadData
}





protocol Session {
    associatedtype Task: DataTask
    
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?,URLResponse?, Error?) -> Void
    ) -> Task
}




final class OfflineURLSession: Session {
    
    var tasks = [URL: OfflineTask]()
    
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?,URLResponse?, Error?) -> Void
    ) -> OfflineTask {
        let task = OfflineTask(completionHandler: completionHandler)
        tasks[url] = task
        return task
    }
}



struct OfflineTask: DataTask {

    typealias Completion = (Data?, URLResponse?, Error?) -> Void
    let completionHandler: Completion

    init(completionHandler: @escaping Completion) {
         self.completionHandler = completionHandler
    }

    func resume() {
         let url = URL(fileURLWithPath: "prepared_response.json")
         let data = try! Data(contentsOf: url)
         completionHandler(data, nil, nil)
    }
}




/// Now you can create the WeatherAPI class and define a
/// generic called Session to allow for a swappable implementation
final class WeatherAPI<S: Session> {
    let session: S
    
    init(session: S) {
        self.session = session
    }
    
    func run() {
        guard let url = URL(string: "https://www.someweatherstartup.com")
        else {
            fatalError("Could not create url")
        }
        let task = session.dataTask(with: url) { (data, response, error) in
            // Work with retrieved data.
        }
        
        task.resume() // Doesn't work, task is of type S.Task
    }
}

private func foo3() {
    let weatherAPI = WeatherAPI(session: URLSession.shared)
    weatherAPI.run()
}










/// Now that you have multiple implementations adhering to Session,
/// you can start swapping them without having to touch the rest of your code.
/// You can choose to create a production WeatherAPI or an offline WeatherAPI.
let productionAPI = WeatherAPI(session: URLSession.shared)
let offlineApi = WeatherAPI(session: OfflineURLSession())




















// MARK: - 13.1.5. Unit testing and Mocking with associated types
class MockSession: Session {
 
    let expectedURLs: [URL]
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation, expectedURLs: [URL]) {
        self.expectation = expectation
        self.expectedURLs = expectedURLs
    }

    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?,URLResponse?, Error?) -> Void
    ) -> MockTask {
        return MockTask(
            expectedURLs: expectedURLs,
            url: url,
            expectation: expectation
        )
     }
}

struct MockTask: DataTask {
    let expectedURLs: [URL]
    let url: URL
    let expectation: XCTestExpectation
 
    func resume() {
        guard expectedURLs.contains(url) else { return }
        self.expectation.fulfill()
    }
}




















///Now, if you want to test your API, you can test that the expected URLs are called.
class APITestCase: XCTestCase {

    var api: API<MockSession>!
 
    func testAPI() {
        let expectation = XCTestExpectation(description: "Expectedsomeweatherstartup.com")
        let session = MockSession(expectation: expectation, expectedURLs: [URL(string: "www.someweatherstartup.com")!])
        api = API(session: session)
        api.run()
        wait(for: [expectation], timeout: 1)
    }
}


private func foo4() {
    let testcase = APITestCase()
    testcase.testAPI()
}






















// MARK: - 13.1.6. Using the Result type
/// Because you’re using a protocol,
/// you can offer a default implementation to all sessions via the use of a protocol extension.
/// You can extend Session and offer a variant that uses Result

protocol Session {
    associatedtype Task: DataTask
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Task
    func dataTask(with url: URL, completionHandler: @escaping (Result<Data, AnyError>) -> Void) -> Task
}

extension Session {
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Result<Data,Error>) -> Void
    ) -> Task {
        return dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                completionHandler(Result.failure(error))
            } else if let data = data {
                completionHandler(Result.success(data))
            } else {
                fatalError()
            }
        })
    }
}





/// Now, implementers of Session, including Apple’s URLSession, can return a Result type.
private func foo5() {
    URLSession.shared.dataTask(with: url) { (result: Result<Data, AnyError>) in
        
    }
    
    OfflineURLSession().dataTask(with: url) { (result: Result<Data, AnyError>) in
        
    }
}














// MARK: - 13.2. Conditional conformance
/// With conditional conformance, you can make a type adhere to a protocol but only under certain conditions.



protocol Track {
    func play()
}

struct AudioTrack: Track {
    let file: URL
    func play() {
        print("playing audio at \(file)")
    }
}









/// This way, you can trigger play() for all Track elements inside an array.
/// This approach has a shortcoming, however, which you’ll solve in a bit.

extension Array where Element: Track {
    func play() {
        for element in self {
            element.play()
        }
    }
}

let tracks = [
    AudioTrack(file: URL(fileURLWithPath: "1.mp3")),
    AudioTrack(file: URL(fileURLWithPath: "2.mp3"))
]




/// But this approach has a shortcoming. Array itself does not conform to Track;
/// it merely implements a method with the same name as the one inside Track, namely the play() method.Because Array doesn’t conform to Track, you can’t call play() anymore on a nested array. Alternatively, if you have a function accepting a Track, you also can’t pass an Array with Track types.
private func foo6() {
    tracks.play() // You use the play() method
    
    let tracks = [
        AudioTrack(file: URL(fileURLWithPath: "1.mp3")),
        AudioTrack(file: URL(fileURLWithPath: "2.mp3"))
    ]

    // If an Array is nested, you can't call play() any more.
    [tracks, tracks].play() // error: type of expression is ambiguous without more context

    // Or you can't pass an array if anything expects the Track protocol.
    func playDelayed<T: Track>(_ track: T, delay: Double) {
      // ... snip
    }

    playDelayed(tracks, delay: 2.0) // argument type '[AudioTrack]' does not conform to expected type 'Track'
}















// MARK: - Making Array conditionally conform to a custom protocol

/// You can make Array conform to Track, but only if its elements conform to Track.
/// The only difference from before is that you add : Track after Array.

// Before. Not conditionally conforming.
extension Array where Element: Track {
    
}

// After. You have conditional conformance.
extension Array: Track where Element: Track {
    func play() {
        for element in self {
            element.play()
        }
    }
}







/// Now Array is a true Track type.
/// You can pass it to functions expecting a Track,
/// or nest arrays with other data and you can still call play() on it, as shown here.

private func foo6() {
    let nestedTracks = [
        [
            AudioTrack(file: URL(fileURLWithPath: "1.mp3")),
            AudioTrack(file: URL(fileURLWithPath: "2.mp3"))
        ],
        [
            AudioTrack(file: URL(fileURLWithPath: "3.mp3")),
            AudioTrack(file: URL(fileURLWithPath: "4.mp3"))
        ]
    ]
    
    // Nesting works.
    nestedTracks.play()
    
    // And, you can pass this array to a function expecting a Track!
    playDelayed(tracks, delay: 2.0)
}


















// MARK: - 13.2.5. Conditional conformance on your types


final class CachedValue<T> {
    private let load: () -> T
    private var lastLoaded: Date

    private var timeToLive: Double
    private var currentValue: T

    public var value: T {
        let needsRefresh = abs(lastLoaded.timeIntervalSinceNow) > timeToLive
        if needsRefresh {
            currentValue = load()
            lastLoaded = Date()
        }
        return currentValue
    }

    init(timeToLive: Double, load: @escaping (() -> T)) {
        self.timeToLive = timeToLive
        self.load = load
        self.currentValue = load()
        self.lastLoaded = Date()
    }
}




private func foo7() {
    let simplecache = CachedValue(timeToLive: 2, load: { () -> String in
        print("I am being refreshed!")
        return "I am the value inside CachedValue"
    })
    
    // Prints: "I am being refreshed!"
    simplecache.value // "I am the value inside CachedValue"
    simplecache.value // "I am the value inside CachedValue"
    
    sleep(3) // wait 3 seconds
    
    // Prints: "I am being refreshed!"
    simplecache.value // "I am the value inside CachedValue"
    
    
}





///MAKING YOUR TYPE CONDITIONALLY CONFORMANT
///Here comes the fun part. 
///Now that you have a generic type, you can get in your starting positions and start adding conditional conformance.
///This way, CachedValue reflects the capabilities of its value inside. 
///For instance, you can make CachedValue Equatable if its value inside is Equatable.
///You can make CachedValue Hashable if its value inside is Hashable, 
///and you can make CachedValue Comparable if its value inside is Comparable


// Conforming to Equatable
extension CachedValue: Equatable where T: Equatable {
    static func == (lhs: CachedValue, rhs: CachedValue) -> Bool {
        return lhs.value == rhs.value
    }
}

// Conforming to Hashable
extension CachedValue: Hashable where T: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

// Conforming to Comparable
extension CachedValue: Comparable where T: Comparable {
    static func <(lhs: CachedValue, rhs: CachedValue) -> Bool {
        return lhs.value < rhs.value
    }
    static func ==(lhs: CachedValue, rhs: CachedValue) -> Bool {
        return lhs.value == rhs.value
    }
}







/// Now with conditional conformance in place,
/// CachedValue takes on the properties of its inner type.
/// Let’s try it out and see if CachedValue is properly Equatable, Hashable, and Comparable.
private func foo8() {
    
    let cachedValueOne = CachedValue(timeToLive: 60) {
        // Perform expensive operation
        // E.g. Calculate the purpose of life
        return 42
    }

    let cachedValueTwo = CachedValue(timeToLive: 120) {
        // Perform another expensive operation
        return 1000
    }

    cachedValueOne == cachedValueTwo // Equatable: You can check for equality.
    cachedValueOne > cachedValueTwo // Comparable: You can compare two cached values.

    let set = Set(arrayLiteral: cachedValueOne, cachedValueTwo) // Hashable: You can store CachedValue in a set
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - 13.3. Dealing with protocol shortcomings
    /// TO BE REPEATED!!!

    protocol PokerGame: Hashable {
        func start()
    }

    struct StudPoker: PokerGame {
        func start() {
            print("Starting StudPoker")
        }
    }
    struct TexasHoldem: PokerGame {
        func start() {
            print("Starting Texas Holdem")
        }
    }



    
    
    
    // This won't work!
    var numberOfPlayers = [PokerGame: Int]()
    
    // The error that the Swift compiler throws is:
    //error: using 'PokerGame' as a concrete type conforming to protocol 'Hashable' is not supported
    var numberOfPlayers = [PokerGame: Int]()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - 13.3.2. Type erasing a protocol
    
    
    struct AnyPokerGame: PokerGame {
     
        init<Game: PokerGame>(_ pokerGame: Game)  {
             _start = pokerGame.start
        }

        private let _start: () -> Void
     
        func start() {
            _start()
        }
    }
    
    
    
    
    let studPoker = StudPoker()
    let holdEm = TexasHoldem()

    // You can mix multiple poker games inside an array.
    let games: [AnyPokerGame] = [
        AnyPokerGame(studPoker),
        AnyPokerGame(holdEm)
    ]

    games.forEach { (pokerGame: AnyPokerGame) in
        pokerGame.start()
    }

    // You can store them inside a Set, too
    let setOfGames: Set<AnyPokerGame> = [
        AnyPokerGame(studPoker),
        AnyPokerGame(holdEm)
    ]

    // You can even use poker games as keys!
    var numberOfPlayers = [
        AnyPokerGame(studPoker): 300,
        AnyPokerGame(holdEm): 400
    ]
    
    let studPoker = StudPoker()
    let holdEm = TexasHoldem()

    // You can mix multiple poker games inside an array.
    let games: [AnyPokerGame] = [
        AnyPokerGame(studPoker),
        AnyPokerGame(holdEm)
    ]

    games.forEach { (pokerGame: AnyPokerGame) in
        pokerGame.start()
    }

    // You can store them inside a Set, too
    let setOfGames: Set<AnyPokerGame> = [
        AnyPokerGame(studPoker),
        AnyPokerGame(holdEm)
    ]

    // You can even use poker games as keys!
    var numberOfPlayers = [
        AnyPokerGame(studPoker): 300,
        AnyPokerGame(holdEm): 400
    ]
}














/// You’re almost done. Because PokerGame is also Hashable, you need to make AnyPokerGame adhere to Hashable.
/// In this case, Swift can’t synthesize the Hashable implementation for you because you’re storing a closure.
/// Like a class, a closure is a reference type, which Swift won’t synthesize; so you have to implement Hashable yourself.
/// Luckily, Swift offers the AnyHashable type, which is a type-erased Hashable type.
/// You can store the poker game inside AnyHashable and forward the Hashable methods to the AnyHashable type.
struct AnyPokerGame: PokerGame {

    private let _start: () -> Void
    private let _hashable: AnyHashable
 
    init<Game: PokerGame>(_ pokerGame: Game)  {
        _start = pokerGame.start
        _hashable = AnyHashable(pokerGame)
    }

    func start() {
        _start()
    }
}







/// Congratulations, you’ve erased a type!
/// AnyPokerGame wraps any PokerGame type, and now you’re now free to use AnyPokerGame inside collections.
/// With this technique, you can use protocols with Self requirements—or associated types—and work with them at runtime!
extension AnyPokerGame: Hashable {
 
    func hash(into hasher: inout Hasher) {
        _hashable.hash(into: &hasher)
     }

    static func ==(lhs: AnyPokerGame, rhs: AnyPokerGame) -> Bool {
        return lhs._hashable == rhs._hashable
     }
}






















// MARK: - 13.4. An alternative to protocols

private func foo8() {
    
    protocol Validator {
        associatedtype Value
        func validate(_ value: Value) -> Bool
    }
    
    
    
    struct MinimalCountValidator: Validator {
        let minimalChars: Int
        
        func validate(_ value: String) -> Bool {
            guard minimalChars > 0 else { return true }
            guard !value.isEmpty else { return false } // isEmpty is faster than count check
            return value.count >= minimalChars
        }
    }
    
    
    ///Now, for each different implementation,
    ///you have to introduce a new type conforming to Validator type,
    ///which is a fine approach but requires more boilerplate.
    ///Let’s consider an alternative to prove that you don’t always need protocols.
    
    let validator = MinimalCountValidator(minimalChars: 5)
    validator.validate("1234567890") // true
    
    
    
    
    
    
    
    
    
    
    
    struct Validator<T> {

        let validate: (T) -> Bool

        init(validate: @escaping (T) -> Bool) {
            self.validate = validate
        }
    }

    let notEmpty = Validator<String>(validate: { string -> Bool in
        return !string.isEmpty
    })
    
    notEmpty.validate("") // false
    notEmpty.validate("Still reading this book huh? That's cool!") // true
    
    
    
    
    
    
    
    
    
}


extension Validator {
   func combine(_ other: Validator<T>) -> Validator<T> {
        let combinedValidator = Validator<T>(validate: { (value: T) -> Bool in
            let ownResult = self.validate(value)
            let otherResult = other.validate(value)
            return ownResult && otherResult
        })

       return combinedValidator
    }
}

let notEmpty = Validator<String>(validate: { string -> Bool in
   return !string.isEmpty
})

let maxTenChars = Validator<String>(validate: { string -> Bool in
    return string.count <= 10
})




private func foo9(){
    let combinedValidator: Validator<String> = notEmpty.combine(maxTenChars)
    combinedValidator.validate("") // false
    combinedValidator.validate("Hi") // true
    combinedValidator.validate("This one is way too long") // false
}
