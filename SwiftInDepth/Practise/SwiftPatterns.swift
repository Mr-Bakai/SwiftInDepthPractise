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


