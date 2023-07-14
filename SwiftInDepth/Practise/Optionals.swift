//
//  Optionals.swift
//  SwiftInDepth
//
//  Created by Bakai on 1/7/23.
//

import Foundation
import UIKit

struct Customer {
    let id: String
    let email: String
    let balance: Int // amount in cents
    let firstName: String?
    let lastName: String?
}

/// Details omitted from Swift source.
/// Optionals are Enums
enum TrueOptional<Wrapped> {
  case none
  case some(Wrapped)
}

let customer = Customer(
    id: "30",
    email: "some.mail", 
    balance: 30, 
    firstName: "Jake", 
    lastName: "Freemanson"
)

private func mainFlow() {
    if let firstName = customer.firstName {
        print("\(firstName)")
    }
    
    
    /// Without Swift’s syntactic sugar you’d be matching on optionals everywhere with switch statements.
    switch customer.firstName {
    case .some(let name): print("First name is \(name)")
    case .none: print("Customer didn't enter first name")
    }
    
    
    
    /// You can omit the .some and .none cases from the example below and replace them with let name? and nil,  👆🏻
    switch customer.firstName {
    case let name?: print("First name is \(name)")
    case nil: print("Customer didn't enter first name")
    }
    
    
    
    /// You can handle two optionals at once by unwrapping both
    if let firstName = customer.firstName, let lastName = customer.lastName {
        print("Customer's full name is \(firstName) \(lastName)")
    }
    
    
    
    /// You can unwrap a customer’s firstName and combine it with a Boolean, such as the balance property
    if let firstName = customer.firstName, customer.balance > 0 {
        let welcomeMessage = "Dear \(firstName) you have money on your account, want to spend it on mayonnaise"
    }
    
    
    
    /// You can also pattern match while you unwrap an optional. For example, you can pattern match on balance as well.
    /// You’ll create a notification for the customer when their balance (indicated by cents) has a value that falls inside a range between 4,500 and 5,000 cents
    if let firstName = customer.firstName, 4500..<5000 ~= customer.balance {
        let notification = "Dear \(firstName), you are getting close to afford our $50 tub!"
    }
    
    
    
    
    
    
    
    
    // MARK: - 4.2.3. When you’re not interested in a value
    
    /// You’d like to know whether a customer has a full name filled in, but you aren’t interested in what this name may be
    /// You can again use the “don’t care” wildcard operator to bind the unwrapped values to nothing.
    if
        let _ = customer.firstName,
        let _ = customer.lastName {
        print("The customer entered his full name")
    }
    
    
    /// Alternatively, you can use nil checks for the same effect
    if
        customer.firstName != nil,
        customer.lastName != nil {
        print("The customer entered his full name")
    }
 
    
    /// You can also perform actions when a value is empty
    if
        customer.firstName == nil,
        customer.lastName == nil {
        print("The customer has not supplied a name")
    }
    
    
    
    
    // MARK: - 4.3. Variable shadowing
    let customer = Customer(
        id: "123",
        email: "some.mail",
        balance: 300,
        firstName: "Jake",
        lastName: "Paul"
    )

    /// This print of customer shows customerDescription
    print(customer)
    
}

/// To demonstrate variable shadowing, you’ll create a method that uses the optional properties of Customer.
/// Let’s make Customer conform to the CustomStringConvertible protocol so that you can demonstrate this.
/// By making Customer adhere to the CustomStringConvertible protocol, you indicate that it prints a custom representation in print statements.
/// Conforming to this protocol forces you to implement the description property.

protocol CustomStringConvertible {
    var description: String { get }
}

extension Customer: CustomStringConvertible  {
    var description: String {
        var customerDescription: String = "\(id), \(email)"
        
        if let firstName = firstName {
            customerDescription += ", \(firstName)"
        }
        
        if let lastName = lastName {
            customerDescription += ", \(lastName)"
        }
        
        return customerDescription
    }
}









// MARK: - 4.4.1. Adding a computed property
private func customerStruct4_4_1() {
    
    /// Guards are great for a “none shall pass” approach where optionals are not wanted.
    /// In a moment you’ll see how to get more granular control with multiple optionals.
    struct Customer {
        let id: String
        let email: String
        let balance: Int // amount in cents
        let firstName: String?
        let lastName: String?
        
        var displayName: String {
            guard
                let firstName = firstName,
                let lastName = lastName else {
                    return ""
                }
            
            return "\(firstName) \(lastName)"
        }
    }
    
    let customer = Customer(
        id: "123",
        email: "some.mail",
        balance: 300,
        firstName: "Jake",
        lastName: "Paul"
    )
    
    customer.displayName // Jake Paul
}







// MARK: - 4.5. Returning optional strings

/// The displayName computed property serves its purpose,
/// but a problem occurs when the firstName and lastName properties are nil:
/// displayName returns an empty string, such as "".

/// The benefit of returning an optional String is that you would know at compile-time that displayName may not have a value,
/// whereas with the isEmpty check you’d know it at runtime.
/// This compile-time safety comes in handy when you send out a newsletter to
/// 500,000 people, and you don’t want it to start with “Dear ,”.

private func customerStruct4_5() {
    
    struct Customer {
        let id: String
        let email: String
        let balance: Int // amount in cents
        let firstName: String?
        let lastName: String?
        
        var displayName: String? {
            guard
                let firstName = firstName,
                let lastName = lastName else {
                    return nil
                }
            
            return "\(firstName) \(lastName)"
        }
    }
    
    let customer = Customer(
        id: "123",
        email: "some.mail",
        balance: 300,
        firstName: "Jake",
        lastName: "Paul"
    )
    
    /// Now that displayName returns an optional String, the caller of the method must deal with unwrapping the optional explicitly.
    /// Having to unwrap displayName, as shown next, may be a hassle, but you get more safety in return.
    if let displayName = customer.displayName {
        // createConfirmationMessage(name: displayName, product: "Economy size partytub")
        print(displayName)
    } else {
        // createConfirmationMessage(name: "customer", product: "Economy size partytub")
    }
}












// MARK: - 4.6. Granular control over optionals
private func customer4_6() {
    
    
    /// If only a first name or last name is known,
    /// the displayName function can return either or both of those values, depending on which names are filled in.
    struct Customer {
        let id: String
        let email: String
        let balance: Int // amount in cents
        let firstName: String?
        let lastName: String?
        
        var displayName: String? {
            switch (firstName, lastName) {
            case let (first?, last?): return first + " " + last
            case let (first?, nil): return first
            case let (nil, last?): return last
            default: return nil
            }
        }
    }
    
    
    let customer = Customer(
        id: "123",
        email: "some.mail",
        balance: 300,
        firstName: "Jake",
        lastName: nil
    )
    
    print(customer.displayName)
}














// MARK: - 4.7. Falling back when an optional is nil

private func customer4_7() {
    
    
    /// If only a first name or last name is known,
    /// the displayName function can return either or both of those values, depending on which names are filled in.
    struct Customer {
        let id: String
        let email: String
        let balance: Int // amount in cents
        let firstName: String?
        let lastName: String?
        
        var displayName: String? {
            switch (firstName, lastName) {
            case let (first?, last?): return first + " " + last
            case let (first?, nil): return first
            case let (nil, last?): return last
            default: return nil
            }
        }
    }
    
    
    let customer = Customer(
        id: "123",
        email: "some.mail",
        balance: 300,
        firstName: "Jake",
        lastName: nil
    )
    
    print(customer.displayName)
    
    
    
    
    
    
    // Falling back when an optional is nil
    ///  Notice how title is a String, yet you feed it the customer.displayName optional.
    ///  This means that title will either have the customer’s unwrapped name or fall back to the non-optional “customer” value.
    let title: String = customer.displayName ?? "customer"
}












// MARK: - 4.8. Simplifying optional enums

enum Membership {
    /// 10% discount
    case gold
    /// 5% discount
    case silver
}

private func customer4_8() {
    struct Customer {
        let id: String
        let email: String
        let balance: Int // amount in cents
        let firstName: String?
        let lastName: String?
        let membership: Membership?
        
        var displayName: String? {
            switch (firstName, lastName) {
            case let (first?, last?): return first + " " + last
            case let (first?, nil): return first
            case let (nil, last?): return last
            default: return nil
            }
        }
    }
    
    let customer = Customer(
        id: "123",
        email: "some.mail",
        balance: 300,
        firstName: "Jake",
        lastName: nil,
        membership: .gold
    )
    
    
    /// When you want to read this value, a first implementation tactic could be
    /// to unwrap the enum first and act accordingly.
    
    if let membership = customer.membership {
        switch membership {
        case .gold: print("Gold")
        case .silver: print("Silver")
        }
    } else {
        print("Regular")
    }
    
    
    
    
    /// Here we are matching an ENUM!
    /// Even better, you can take a shorter route and match on the optional enum by using the ? operator.
    /// The ? operator indicates that you are unwrapping and reading the optional membership at the same time.
    switch customer.membership {
    case .gold?: print("Gold")
    case .silver?: print("Silver")
    default: print("Regular")
    }
}








// MARK: - Good to know
private func customer4_9() {
    // 4.10.1. Reducing a Boolean to two states
    
    /// When you want to treat a nil as false, making it a regular Boolean straight away can be beneficial,
    /// so dealing with an optional Boolean doesn’t propagate far into your code.
    /// You can do this by using a fallback value, with help from the nil-coalescing operator- ??.
    let preferences = ["autoLogin": true, "faceIdEnabled": true]
    let isFaceIdEnabled = preferences["faceIdEnabled"] ?? false
    
    
    
    
    
    
    
    
    
    // 4.10.2. Falling back on true
    /// Here’s a counterpoint: blindly falling back to false is not recommended.
    /// Depending on the scenario, you may want to fall back on a true value instead.
    
    /// Consider a scenario where you want to see whether a customer has Face ID enabled
    /// so that you can direct the user to a Face ID settings screen. In that case, you can fall back on true instead.
    
    if preferences["faceIdEnabled"] ?? true {
        // go to Face ID settings screen.
    } else {
        // customer has disabled Face ID
    }
}









// MARK: - 4.10.4. Implementing RawRepresentable

private func customer4_10() {
    
    enum UserPreference: RawRepresentable {
        case enabled
        case disabled
        case notSet

        init(rawValue: Bool?) {
             switch rawValue {
               case true?: self = .enabled
               case false?: self = .disabled
               default: self = .notSet
             }
        }

        var rawValue: Bool? {
             switch self {
               case .enabled: return true
               case .disabled: return false
               case .notSet: return nil
             }
        }
    }
}











// MARK: - 4.11. Force unwrapping guidelines

private func optional4_11() {
    
    
    /// Take Foundation’s URL type, for example. It accepts a String parameter in its initializer.
    /// Then a URL is either created or not, depending on whether the
    /// passed string is a proper path—hence URL’s initializer can return nil.
    let optionalUrl = URL(string: "https://www.themayonnaisedepot.com")
    // Optional(http://www.themayonnaisedepot.com)
    
    
    
    
    
    
    
    
    /// You can force unwrap the optional by using an exclamation mark, bypassing any safe techniques.
    let forceUnwrappedUrl = URL(string: "https://www.themayonnaisedepot.com")!
    // http://www.themayonnaisedepot.com. Notice how we use the ! to forceunwrap.
    
    
    
    
    
    
    
    
    // IUO
    /// This is a good scenario for an IUO. By making the chat service an IUO,
    /// you don’t have to pass the chat service to the process monitor’s initializer,
    /// but you don’t need to make chat service an optional, either.
    
    class ChatService {
        var isHealthy = true
    }

    class ProcessMonitor {

        var chatService: ChatService! // IUO
     
        class func start() -> ProcessMonitor {
            // In a real-world application: run elaborate diagnostics.
            return ProcessMonitor()
        }

        func status() -> String {
            if chatService.isHealthy {
                return "Everything is up and running"
            } else {
                return "Chatservice is down!"
            }
        }
    }
    
    
    
    
    
    /// This way you can kick off the processMonitor first, but you have
    /// the benefit of having chatService available to processMonitor right before you need it.
    
    let processMonitor = ProcessMonitor.start()
    // processMonitor runs important diagnostics here.
    // processMonitor is ready.

    let chat = ChatService() // Start Chatservice.

    processMonitor.chatService = chat
    processMonitor.status() // "Everything is up and running"
    
    
    
    
    
    
    
    
    /// But chatService is an IUO, and IUOs can be dangerous.
    /// If you for some reason accessed the chatService property
    /// before it passed to processMonitor, you’d end up with a crash.

    let processMonitorB = ProcessMonitor.start()
    processMonitor.status() // fatal error: unexpectedly found nil
}
