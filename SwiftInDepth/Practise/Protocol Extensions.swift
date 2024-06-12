//
//  Protocol Extensions.swift
//  SwiftInDepth
//
//  Created by Bakai Ismaiilov on 31/10/23.
//

import Foundation
import UIKit

// MARK: - 12.1.2. Creating a protocol extension

protocol RequestBuilder {
    var baseUrl: URL { get set }
    func makeRequest(path: String) -> URLRequest
}

extension RequestBuilder {
    func makeRequest(path: String) -> URLRequest {
        let url = baseUrl.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 30
        return request
    }
}




private func foo1() {
    
    /// To get the implementation of `makeRequest` for free,
    /// you merely have to conform to the `RequestBuilder` protocol.
    struct BikeRequestBuilder: RequestBuilder {
        var baseUrl: URL
    }
    
    let bikeRequestBuilder = BikeRequestBuilder(baseUrl: URL(string: "https://www.biketriptracker.com")!)
    let request = bikeRequestBuilder.makeRequest(path: "/trips/all")
    print(request) // https://www.biketriptracker.com/trips/all
}




// MARK: - 12.1.3. Multiple extensions
/// A type is free to conform to multiple protocols.
/// Imagine having a `BikeAPI` that both builds requests and handles the response.
enum ResponseError: Error {
    case invalidResponse
}

protocol ResponseHandler {
     func validate(response: URLResponse) throws
}

extension ResponseHandler {
    func validate(response: URLResponse) throws {
        guard let httpresponse = response as? HTTPURLResponse else {
            throw ResponseError.invalidResponse
        }
    }
}

class BikeAPI: RequestBuilder, ResponseHandler {
    var baseUrl: URL
    
    init(baseUrl: URL) {
        self.baseUrl = baseUrl
    }
    
   // let baseURL: URL = URL(string: "https://www.biketriptracker.com"), TODO: to be checked, why it is not compiling tho
}














// MARK: - 12.2. Protocol inheritance vs. Protocol composition
// 12.2.1. Builder a mailer

/// A `MailAddress` shows more intent than simply using a String.
/// You also define the `Mailer` protocol with a default implementation
/// via a protocol extension (implementation omitted).
struct MailAddress {
     let value: String
}

struct Email {
    let subject: String
    let body: String
    let to: [MailAddress]
    let from: MailAddress
}

protocol Mailer {
    func send(email: Email) throws
 }


/// Not all mailers validate, so you can’t assume that `Mailer` validates an email by default.
extension Mailer {
    func send(email: Email) {
        // Omitted: Connect to server
        // Omitted: Submit email
        print("Email is sent!")
    }
}















// MARK: - 12.2.2. Protocol inheritance
/// If you do want to offer a default implementation that allows for sending validated emails,
/// you can take at least two approaches.
/// You’ll start with a protocol inheritance approach and
/// then switch to a composition approach to see both pros and cons.


/// To make life easier for implementers of `ValidatingMailer`,
/// you extend `ValidatingMailer` and offer a default `send(email:)` method from `Mailer`,
/// which uses the `validate(email:)` method before sending.
/// Again, to focus on the API, implementations are omitted, as shown in this listing.
protocol ValidatingMailer: Mailer {
    func validate(email: Email) throws
}

extension ValidatingMailer {
    func send(email: Email) throws {
        try validate(email: email)
        // Connect to server
        // Submit email
        print("Email validated and sent.")
    }

    func validate(email: Email) throws {
        // Check email address, and whether subject is missing.
    }
}



/// Now, SMTPClient implements `ValidatingMailer` and automatically get’s a `validated send(email:)` method.
struct SMTPClient: ValidatingMailer {
    // Implementation omitted.
}


/// `A downside of protocol inheritance is that you don’t separate functionality and semantics.`
/// For instance, because of protocol inheritance, anything that validates emails automatically has to be a `Mailer`
/// You can loosen this restriction by applying protocol composition—let’s do that now.
private func foo3() {
    let client = SMTPClient()
    try? client.send(email: Email(subject: "Learn Swift",
                                  body: "Lorem ipsum",
                                  to: [MailAddress(value: "john@appleseed.com")],
                                  from: MailAddress(value: "stranger@somewhere.com")))
}












// MARK: - 12.2.3. The composition approach

/// For the composition approach, you keep the Mailer protocol.
/// But instead of a Validating-Mailer that inherits from Mailer,
/// you offer a standalone MailValidator protocol that doesn’t inherit from anything.
/// The MailValidator protocol also offers a default implementation via an extension, which you omit for brevity as shown here.

protocol MailValidator {
    func validate(email: Email) throws
}

extension MailValidator {
    func validate(email: Email) throws {
        // Omitted: Check email address, and whether subject is missing.
    }
}






/// Now you can compose.
/// You make `SMTPClient` conform to both separate protocols.
/// Mailer does not know about `MailValidator`, and vice versa

/// With the two protocols in place,
/// you can create an extension that only works on a protocol intersection.

/// To create an extension with an intersection,
/// you extend one protocol that conforms to the other via the `Self` keyword.
extension MailValidator where Self: Mailer {
 
    func send(email: Email) throws {
        try validate(email: email)
        // Connect to server
        // Submit email
        print("Email validated and sent.")
    }
}






/// Another benefit of this approach is that you can come up with new methods such as `send(email:, at:)`
/// You can define new methods on a protocol intersection.
extension MailValidator where Self: Mailer {
    // ... snip

    func send(email: Email, at: Date) throws {
         try validate(email: email)
        // Connect to server
        // Add email to delayed queue.
        print("Email validated and stored.")
    }
}












// MARK: - 12.2.4. Unlocking the powers of an intersection



/// Now, you’re going to make SMTPClient adhere to both the Mailer and MailValidator protocols,
/// which unlocks the code inside the protocol intersection.
/// In other words, `SMTPClient` gets the validating `send(email:)` and `send(email:, at:)` methods for free.

struct SMTPClient2: Mailer, MailValidator {}


private func foo5() {
    let client = SMTPClient2()
    let email = Email(subject: "Learn Swift",
                      body: "Lorem ipsum",
                      to: [MailAddress(value: "john@appleseed.com")],
                      from: MailAddress(value: "stranger@somewhere.com"))
    
    try? client.send(email: email) // Email validated and sent.
    try? client.send(email: email, at: Date(timeIntervalSinceNow: 3600)) // Email validated and queued.
    
    
    
    
    
    
    
    
    
    
    /// Another way to see the benefits is via a generic function.
    /// When you constrain to both protocols, the intersection implementation becomes available.
    /// Notice how you define the generic `T` and constrain it to both protocols.
    /// By doing so, the delayed `send(email:, at:)` method becomes available.
    
    func submitEmail<T>(sender: T, email: Email) where T: Mailer, T: MailValidator {
        try? sender.send(email: email, at: Date(timeIntervalSinceNow: 3600))
    }
}






// MARK: - 12.2.5. Exercise ✅

protocol Mentos {
    func fixAllBugs()
}

protocol Coke {
    func fixHelper()
}

extension Mentos where Self: Coke {
    func explode() {
        print("This is a bad idea to mix them up")
    }
}

func mix<T>(concoction: T) where T: Mentos, T: Coke {
     concoction.explode()  // make this work, but only if T conforms to both protocols, not just one
}





protocol Plant {
    func grow()
}

extension Plant {
     func grow() {
        print("Growing a plant")
    }
}
protocol Tree: Plant {}
 
extension Tree {
    func grow() {
         print("Growing a tree")
    }
}

struct Oak: Tree {
    func grow() {
         print("The mighty oak is growing")
    }
}

struct CherryTree: Tree {}
 
struct KiwiPlant: Plant {}
 

private func foo6() {
 
    // TODO: TO BE REVIEWED on MANNING
    func growPlant<P: Plant>(_ plant: P) {
         plant.grow()
    }
    
    growPlant(Oak()) // The mighty oak is growing
    growPlant(CherryTree()) // Growing a tree
    growPlant(KiwiPlant()) // Growing a plant
}








// MARK: - 12.4.1. Opting in to extensions

/// Imagine that you have an `AnalyticsProtocol` protocol that helps track analytic events for user metrics.
/// You could implement `AnalyticsProtocol` on `UIViewController`, which offers a default implementation.
/// This adds the functionality of `Analytics-Protocol` to all `UIViewController` types and its subclasses.

/// But assuming that all viewcontrollers need to conform to this protocol is probably not safe.
/// If you’re delivering a framework with this extension, a developer implementing this framework gets this extension automatically, whether they like it or not.
/// Even worse, the extension from a framework could clash with an existing extension in an application if they share the same name!
/// One way to avoid these issues is to flip the extension.

protocol AnalyticsProtocol {
    func track(event: String, parameters: [String: Any])
}

/// `Not like this:`
// extension UIViewController: AnalyticsProtocol {
//     func track(event: String, parameters: [String: Any]) { // ... snip
//
//     }
// }

// But as follows:
extension AnalyticsProtocol where Self: UIViewController {
    func track(event: String, parameters: [String: Any]) { // ... snip
        
    }
}


class NewsViewController: UIViewController {}

extension NewsViewController: AnalyticsProtocol {
    // ... snip

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
        track(event: "News.appear", parameters: [:])
    }
}










// MARK: - 12.5. Extending with associated types


/// Let’s extend Array. 
/// To be able to check each element for equality, you need to make sure that an `Element` is `Equatable`,
/// which you can express via a constraint.
/// Constraining `Element` to `Equatable` means that unique() is only available on arrays with `Equatable` elements.
extension Array where Element: Equatable {
     func unique() -> [Element] {
        var uniqueValues = [Element]()
        for element in self {
            if !uniqueValues.contains(element) {
                 uniqueValues.append(element)
            }
        }
        return uniqueValues
    }
}






/// Extending Array is a good start.
/// But it probably makes more sense to give this extension to many types of collections,
/// not only Array but perhaps also the values of a dictionary or even strings.
/// You can go a bit lower-level and decide to extend the Collection protocol instead, as shown here,
/// so that multiple types can benefit from this method.
/// Shortly after, you’ll discover a shortcoming of this approach.

/// This time we're extending Collection instead of Array
extension Collection where Element: Equatable {
    func unique() -> [Element] {
        var uniqueValues = [Element]()
        for element in self {
            if !uniqueValues.contains(element) {
                uniqueValues.append(element)
            }
        }
        return uniqueValues
    }
}





/// Now, every type adhering to the Collection protocol inherits the unique() method. Let’s try it out.
/// Extending Collection instead of `Array` benefits more than one type,
/// which is the benefit of extending a protocol versus a concrete type.

private func foo4() {
    // Array still has unique()
    [3, 2, 1, 1, 2, 3].unique() // [3, 2, 1]

    // Strings can be unique() now, too
    "aaaaaaabcdef".unique() // ["a", "b", "c", "d", "e", "f"]

    // Or a Dictionary's values
    let uniqueValues = [1: "Waffle",
     2: "Banana",
     3: "Pancake",
     4: "Pancake",
     5: "Pancake"
    ].values.unique()

    print(uniqueValues) // ["Banana", "Pancake", "Waffle"]
}









// MARK: - 12.5.1. A specialized extension

/// One thing remains.
/// The unique() method is not very performant.
/// For every value inside the collection, you need to check if this value already exists in a new unique array,
/// which means that for each element, you need to loop through (possibly) the whole uniqueValues array.
/// You would have more control if Element were Hashable instead.
/// Then you could check for uniqueness via a hash value via a Set, 
/// which is `much faster than an array lookup because a Set doesn’t keep its elements in a specific order.`


// This extension is an addition, it is NOT replacing the other extension.
extension Collection where Element: Hashable { /// You extend Collection only for elements that are Hashable.
     func unique() -> [Element] {
        var set = Set<Element>()
        var uniqueValues = [Element]()
        for element in self {
            if !set.contains(element) {
                uniqueValues.append(element)
                set.insert(element)
            }
        }
        return uniqueValues
    }
}








// MARK: - 12.6. Extending with concrete constraints



/// You can also constrain associated types to a concrete type instead of constraining to a protocol. 
/// As an example, let’s say you have an `Article` struct with a `viewCount` property,
/// which tracks the number of times that people viewed an `Article`.


struct Article: Hashable {
    let viewCount: Int
}




/// You can extend `Collection` to get the total number of view counts inside a `collection`.
/// But this time you constrain an `Element` to `Article`, as shown in the following.
/// Since you’re constraining to a concrete type, you can use the `==` operator.


// Not like this
extension Collection where Element: Article { /* snip...*/ }

// But like this
extension Collection where Element == Article {
    var totalViewCount: Int {
        var count = 0
        for article in self {
            count += article.viewCount
        }
        return count
    }
}






/// With this constraint in place,
/// you can get the total view count whenever you have a collection with articles in it,
/// whether that’s an Array, a Set, or something else altogether.

private func fooooo() {
    let articleOne = Article(viewCount: 30)
    let articleTwo = Article(viewCount: 200)

    // Getting the total count on an Array.
    let articlesArray = [articleOne, articleTwo]
    articlesArray.totalViewCount // 230

    // Getting the total count on a Set.
    let articlesSet: Set<Article> = [articleOne, articleTwo]
    articlesSet.totalViewCount // 230
}
