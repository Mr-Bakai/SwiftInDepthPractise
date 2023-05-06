//
//  Associated Types.swift
//  SwiftInDepth
//
//  Created by Bakai on 2/4/23.
//

import UIKit

protocol WorkerSimple {
    
    @discardableResult
    func start(input: String) -> Bool
}

class MailJobSimple: WorkerSimple {
    func start(input: String) -> Bool {
        
        return true
    }
}



// MARK: -Listing 8 - 12
protocol Input {}
protocol Output {}

protocol Worker812 {
    @discardableResult
    func start(input: Input) -> Output
}




//MARK: -8.2.4. Modeling a protocol with associated types

/*
 Now the Input and Output generics are declared as associated types.
 Associated types are similar to generics, but they are defined inside a protocol.
 Notice how Worker does not have the <Input, Output> notation.
 */

protocol Worker {
    associatedtype Input
    associatedtype Output
 
    @discardableResult
    func start(input: Input) -> Output
}



// MARK: - 8.2.5. Implementing a PAT

/*
 Looking at the details of MailJob in the next listing,
 you can see that it sets the Input and Output to concrete types.
 */

class MailJob: Worker {
    typealias Input = String
    typealias Output = Bool
    
    func start(input: Input) -> Output {
     
        return true
    }
}

// 👆🏻 Now, MailJob always uses String and Bool for its Input and Output.

/*
 Each type conforming to a protocol can only have a single implementation of a protocol.
 But you still get generic values with the help of associated types.
 The benefit is that each type can decide what these associated values represent.
 */


// MARK: Listing 8.17. The FileRemover

class FileRemover: Worker {
//    typealias Input = URL
//    typealias Output = [String]
    
    func start(input: URL) -> [String] {
        do {
            var results = [String]()
            let fileManager = FileManager.default
            let fileURLs = try fileManager.contentsOfDirectory(at: input,
                                                               includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
                results.append(fileURL.absoluteString)
            }
            
            return results
        } catch {
            print("Clearing directory failed.")
            return []
        }
    }
}

/*
 TIPS 💡
 Another way to think of an "associated type" is that it’s a generic,
 except it’s a generic that lives inside a protocol.
 */



// MARK: - 8.3. Passing protocols with associated types


/*
 With runWorker in place, you can pass it multiple Worker types,
 such as a MailJob or a FileRemover, as shown in the next listing.
 Make sure that you pass matching Input types for each worker;
 you pass strings for MailJob and URLs to FileRemover.
 */


func runWorker<W: Worker>(worker: W, input: [W.Input]) {
    input.forEach { (value: W.Input) in
        worker.start(input: value)
    }
}

let mailJob = MailJob()

// runWorker(worker: mailJob, input: ["grover@sesamestreetcom", "bigbird@sesamestreet.com"])
 
let fileRemover = FileRemover()
// runWorker(worker: fileRemover, input: [
//    URL(fileURLWithPath: "./cache", isDirectory: true),
//    URL(fileURLWithPath: "./tmp", isDirectory: true),
//    ])


// MARK: - Constraining with Where clouse
func constrainingWithWhere() {
    
    final class User {
        let firstName: String
        let lastName: String
        init(firstName: String, lastName: String) {
            self.firstName = firstName
            self.lastName = lastName
        }
    }
    
    /*
     For instance, let’s say you want to process an array of users;
     perhaps you need to strip empty spaces from their names or update other values.
     You can pass an array of users to a single worker.
     You can make sure that the Input associated type is of type User with the help of a
     where clause so that you can print the users’ names the worker is processing.
     By constraining an associated type, the function is specialized to work only with users as input.
     */
    
    func runWorker<W>(worker: W, input: [W.Input]) where W: Worker, W.Input == User {
         input.forEach { (user: W.Input) in
            worker.start(input: user)
            print("Finished processing user \(user.firstName) \(user.lastName)")
         }
    }
}


// MARK: - 8.3.2. Types constraining associated types

final class ImageCropper: Worker {
    typealias Input = UIImage
    typealias Output = Bool
    
    let size: CGSize
    init(size: CGSize) {
        self.size = size
    }
    
    func start(input: Input) -> Output {
        
        return true
    }
}



/*
 You can constrain the associated types of Worker with a where clause.
 You can write this where clause before the opening brackets of ImageProcessor, as shown here.
 */

final class ImageProcessor<W: Worker> where W.Input == UIImage, W.Output == Bool {
 
    let worker: W

    init(worker: W) {
        self.worker = worker
    }

    private func process() {
        // start batches

        let amount = 50
        var offset = 0
        var images = fetchImages(amount: amount, offset: offset)
        var failedCount = 0
        while !images.isEmpty {
 
            for image in images {
                if !worker.start(input: image) {
                     failedCount += 1
                }
            }

            offset += amount
            images = fetchImages(amount: amount, offset: offset)
        }

        print("\(failedCount) images failed")
    }

    private func fetchImages(amount: Int, offset: Int) -> [UIImage] {
        // Not displayed: Return images from database or harddisk
        return [UIImage(), UIImage()]
     }
}


// MARK: - 8.3.3. Cleaning up your API with protocol inheritance

/*
 For convenience, you can apply protocol inheritance to further constrain a protocol.
 Protocol inheritance means that you create a new protocol that inherits the definition of another protocol.
 Think of it like subclassing a protocol.
 */

/*
 In this case, ImageWorker is empty, but note that you can add extra protocol definitions to it if you’d like.
 Then types adhering to ImageWorker must implement these on top of the Worker protocol.
 */


protocol ImageWorker: Worker where Input == UIImage, Output == Bool {
    // extra methods can go here if you want
}

// class signature is shortened

class Listing_8_25_No_need_to_constrain_anymore {
    // Before:
    final class ImageProcessor<W: Worker> where W.Input == UIImage, W.Output == Bool { /* ... */}
    
    // After:
    final class ImageProcessor2<W: ImageWorker> { /* ... */ }
}



































// MARK: - 8.3.4. Exercises


protocol Playable {
    associatedtype Media
    
    var contents: Media { get }
    func play()
}


final class Movie: Playable {
    typealias Media = URL
    var contents: Media
    
    //  typealias Media = URL ===> this can be ommited coz type will be inferred from contents type
    //  var contents: URL
    
    init(contents: Media) {
        self.contents = contents
    }

    func play() { print("Playing video at \(contents)") }
}


struct AudioFile {}

final class Song2: Playable {
    let contents: AudioFile
    
    init(contents: AudioFile) {
        self.contents = contents
    }

    func play() { print("Playing song") }

}


final class Playlist<P: Playable> {
    private var queue: [P] = []

    func addToQueue(playable: P) {
        queue.append(playable)
    }

    func start() {
        queue.first?.play()
    }
}


final class Portfoli4o {
    var coins: [CryptoCurrency]
 
    init(coins: [CryptoCurrency]) {
        self.coins = coins
    }
}
