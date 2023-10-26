//
//  ErrorHandling.swift
//  SwiftInDepth
//
//  Created by Bakai on 14/7/23.
//

import Foundation



/// 📒Programming errors—
/// These errors could have been prevented by a programmer with a good night’s sleep—for example,
/// arrays being out of bounds, division by zero, and integer overflows.
/// Essentially, these are problems that you can fix on a code level.
/// This is where unit tests and quality assurance can save you when you drop the ball.
/// Usually, in Swift you can use checks such as assert to make sure your code acts as intended, and precondition to let others know that your
/// API is called correctly. Assertions and preconditions are not what this chapter covers, however.


/// 📒User errors—
/// A user error is when a user interacts with a system and fails to complete a task correctly,
/// such as accidentally sending drunk selfies to your boss.
/// User errors can be caused by not completely understanding a system, being distracted, or a clumsy user interface.
/// Even though faulting a customer’s intelligence may be a fun pastime,
/// you can blame a user error on the application itself, and you can prevent these issues with good design,
/// clear communication, and shaping your software in such as way that it helps users reach their intent.


/// 📒Errors revealed at runtime—
/// These errors could be an application being unable to create a file because the hard drive is full,
/// a network request that fails, certificates that expire, JSON parsers that barf up after being fed wrong data,
/// and many other things that can go wrong when an application is running.
/// This last category of errors are recoverable (generally speaking) and are what this chapter focuses on.










/// Swift offers an Error protocol,
/// which you can use to indicate that something went wrong in your application.

enum ParseLocationError: Error {
    case invalidData
    case locationDoesNotExist
    case middleOfTheOcean
}

/// At first glance, enums are the way to go when composing errors,
/// but know that you’re not restricted to using them for specific cases.




/// 📝Errors exist to be thrown and handled.
/// For instance, when a function fails to save a file, it can throw an error with a reason,
/// such as the hard drive being full or lacking the rights to write to disk.
/// When a function or method can throw an error,
/// Swift requires the throws keyword in the function signature behind the closing parenthesis.




/// A parseLocation function can then convert the strings by parsing them.
/// If the parsing fails, the parseLocation function throws a ParseLocation-Error.invalidData error.


struct Location {
    let latitude: Double
    let longtitude: Double
}










/// A parseLocation function can then convert the strings by parsing them.
/// If the parsing fails, the parseLocation function throws a ParseLocation-Error.invalidData error.
/// The parseLocation function either returns a Location or throws an error




/// Turns two strings with a latitude and longitude value into a Location type
/// - Parameters:
///   - latitude: a String containing a latitude value
///   - longtitude: a String containing a longtitude value
/// - Throws: Will throw a ParseLocationError.invalidData if lat and long  can't be converted to Double.
/// - Returns: a Location struct
private func pareseLocation(_ latitude: String, _ longtitude: String) throws -> Location {
    guard
        let latitude = Double(latitude),
        let longtitude = Double(longtitude)
    else {
        throw ParseLocationError.invalidData
    }
    return Location(latitude: latitude, longtitude: longtitude)
}



/// Cmd-Alt-/ for generating quick help documentation




private func error6_3() {
    
    /// Because parseLocation is a throwing function, as indicated by the `throws` keyword,
    /// you need to call it with the `try` keyword.
    do {
        try pareseLocation("I am not a double, you dick head", "4.123123123")
    } catch {
        print(error)
    }
}






/// 📝Another peculiar aspect of Swift’s error handling is that functions don’t reveal which errors they can throw.
/// A function that is marked as throws could theoretically throw no errors or five million different errors,
/// and you have no way of knowing this by looking at a function signature.
/// Not having to list and handle each error explicitly gives you flexibility,
/// but a significant shortcoming is that you can’t quickly know which errors a function can produce or propagate.
///
/// Functions don’t reveal their errors, so giving some information where possible is recommended.













// MARK: - 6.1.4. Keeping the environment in a predictable state

/// Keeping an application in a predictable state means that when a function or method throws an error,
/// it should prevent, or undo, any changes that it has done to the environment or instance.



/// Let’s say you own a memory cache, and you want to store a value to this cache via a method.
/// If this method throws an error, you probably expect your value not to be cached.
/// If the function keeps the value in memory on an error, however, an external retry mechanism may even cause the system to run out of memory.
/// The goal is to get the environment back to normal when throwing errors so the caller can retry or continue in other ways.




/// The easiest way to prevent throwing functions from mutating
/// the environment is if functions don’t even change the environment in the first place.
/// Making a function immutable is one way to achieve this.
/// Immutable functions and methods have benefits in general, but even more so when a function is throwing.

/// If you look back at the parseLocation function, you see that it touches only the values that it gets passed,
/// and it isn’t performing any changes to external values, meaning that there are no hidden side effects.
/// Because parseLocation is immutable, it works predictably.







// MARK: - MUTATING TEMPORARY VALUES

/// A second way that you can keep your environment in a predictable state is by mutating a copy or
/// temporary value and then saving the new state after the mutation completed without errors.




enum ListError: Error {
    case invalidValue
}




/// Consider the following TodoList type, which can store an array of strings.
/// If a string is empty after trimming, however, the append method throws an error.


struct TodoList {
    private var values = [String]()
    
    mutating func append(strings: [String]) throws {
        
        for string in strings {
            let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedString.isEmpty {
                throw ListError.invalidValue
            } else {
                values.append(trimmedString)
            }
        }
    }
}



/// The problem is that after append throws an error, the type now has a half-filled state. 👆🏻
/// The caller may assume everything is back to what it was and retry again later.
/// But in the current state, the TodoList leaves some trailing information in its values.


/// Instead, you can consider mutating a temporary value, and only adding
/// the final result to the actual values property after every iteration was successful. 👇🏻
/// If the append method throws during an iteration, however, the new state is never saved,
/// and the temporary value will be gone, keeping the TodoList in the same state as before an error is thrown.



private func error_todo_struct() {
    
    struct TodoList {
        
        private var values = [String]()
        
        mutating func append(strings: [String]) throws {
            
            var trimmedStrings = [String]() /// A temporary array is created.
            for string in strings {
                let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if trimmedString.isEmpty {
                    throw ListError.invalidValue
                } else {
                    trimmedStrings.append(trimmedString) /// The temporary array is modified
                }
            }
            
            values.append(contentsOf: trimmedStrings) /// If no error is thrown, the values property is updated.
        }
    }
}















// MARK: - RECOVERY CODE WITH DEFER





/// One way to recover from a throwing function is to undo mutations while being in the middle of an operation.
/// Undoing mutating operations halfway tends to be rarer,
/// but can be the only option you may have when you are writing data, such as files to a hard drive.



/// This function problems to be revisioned on the book!

func writeToFiles(data: [URL: String]) throws {
    var storedUrls = [URL]()
    defer {
        if storedUrls.count != data.count {
            for url in storedUrls {
                try! FileManager.default.removeItem(at: url)
            }
        }
    }
    
    for (url, contents) in data {
        try contents.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        storedUrls.append(url)
    }
}









// MARK: - Propagating errors




/// When the extractRecipe function is called on RecipeExtractor,
/// it will call a lower-level function called parseWebpage, which in turn will call parseIngredients and parseSteps.
/// Both parseIngredients and parseSteps can throw an error,
/// which parseWebpage will receive and propagate back up to the extractRecipe function as shown in the following code.




struct Recipe {
    let ingredients: [String]
    let steps: [String]
}

enum ParseRecipeError: Error {
    case parseError
    case noRecipeDetected
    case noIngredientsDetected
}

struct RecipeExtractor {
    
    let html: String
    
    
    
    
    ///  If the catch clause were matching on specific errors,
    ///  theoretically some errors would not be caught and would have to propagate up even higher,
    ///  making the extract-Recipe function throwing as well.
    func extractRecipe() -> Recipe? {
        do {
            return try parseWebpage(html)
        } catch {
            print("Could not parse recipe")
            return nil
        }
    }
    
    private func parseWebpage(_ html: String) throws -> Recipe {
        let ingredients = try parseIngredients(html)
        let steps = try parseSteps(html)
        return Recipe(ingredients: ingredients, steps: steps)
    }
    
    private func parseIngredients(_ html: String) throws -> [String] {
        // ... Parsing happens here
        
        // .. Unless an error is thrown
        throw ParseRecipeError.noIngredientsDetected
    }
    
    private func parseSteps(_ html: String) throws -> [String] {
        // ... Parsing happens here
        
        // .. Unless an error is thrown
        throw ParseRecipeError.noRecipeDetected
    }
}












// MARK: - 6.2.2. Adding technical details for troubleshooting







/// You know precisely which action failed and what the state is of each variable in the proximity of the error.
/// When an error gets propagated up, this exact state may get lost, losing some useful information to handle the error.



/// When logging an error to help the troubleshooting process,
/// adding some useful information for developers can be beneficial,
/// such as where the parsing of recipes failed, for instance.
/// After you’ve added this extra information,
/// you can pattern match on an error and extract the information when troubleshooting.


private func error6_9() {
    
    enum ParseRecipeError: Error {
        case parseError(line: Int, symbol: String)
        case noRecipeDetected
        case noIngredientsDetected
    }
    
    
    
    
    /// This way, you can pattern match against the cases more explicitly when troubleshooting.
    /// Notice how you still keep a catch clause in there, to prevent extractRecipes from becoming a throwing function.
    
    struct RecipeExtractor {
        
        let html: String
        
        func extractRecipe() -> Recipe? {
            do {
                return try parseWebpage(html)
            } catch let ParseRecipeError.parseError(line, symbol) {
                print("Parsing failed at line: \(line) and symbol: \(symbol)")
                return nil
            } catch {
                print("Could not parse recipe")
                return nil
            }
        }
        
        private func parseWebpage(_ html: String) throws -> Recipe {
            let ingredients = try parseIngredients(html)
            let steps = try parseSteps(html)
            return Recipe(ingredients: ingredients, steps: steps)
        }
        
        private func parseIngredients(_ html: String) throws -> [String] {
            // ... Parsing happens here
            
            // .. Unless an error is thrown
            throw ParseRecipeError.noIngredientsDetected
        }
        
        private func parseSteps(_ html: String) throws -> [String] {
            // ... Parsing happens here
            
            // .. Unless an error is thrown
            throw ParseRecipeError.noRecipeDetected
        }
    }
    
}










// MARK: - ADDING USER-READABLE INFORMATION






/// One approach to get human-readable information is to incorporate the Localized-Error protocol.
/// When adhering to this protocol, you indicate that the error follows certain conventions and contains user-readable information.
/// Conforming to Localized-Error tells an error handler that information
/// is present that it can confidently show the user without needing to do some conversion.

enum ParseRecipeError2: Error {
    case parseError(line: Int, symbol: String)
    case noRecipeDetected
    case noIngredientsDetected
}



extension ParseRecipeError2: LocalizedError {
    
    
    
    /// the errorDescription property, which can give more information about the error itself.
    var errorDescription: String? {
        switch self {
        case .parseError:
            return NSLocalizedString("The HTML file had unexpected symbols.",
                                     comment: "Parsing error reason unexpected symbols")
        case .noIngredientsDetected:
            return NSLocalizedString("No ingredients were detected.",
                                     comment: "Parsing error no ingredients.")
        case .noRecipeDetected:
            return NSLocalizedString("No recipe was detected.",
                                     comment: "Parsing error no recipe.")
        }
    }
    
    
    
    
    
    
    /// the failureReason property, which helps explain why an error failed.
    var failureReason: String? {
        switch self {
        case let .parseError(line: line, symbol: symbol):
            return String(format: NSLocalizedString(
                "Parsing data failed at line: %i and symbol: %@",
                comment: "Parsing error line symbol"), line, symbol)
            
        case .noIngredientsDetected:
            return NSLocalizedString(
                "The recipe seems to be missing its ingredients.",
                comment: "Parsing error reason missing ingredients.")
            
        case .noRecipeDetected:
            return NSLocalizedString(
                "The recipe seems to be missing a recipe.",
                comment: "Parsing error reason missing recipe.")
        }
    }
    
    
    
    
    
    
    /// The recovery-Suggestion to help users with an action of what they should do,
    /// which in this case is to try a different recipe page.
    var recoverySuggestion: String? {
        return "Please try a different recipe."
    }
}














// MARK: - BRIDGING TO NSError





/// With a little effort, you can implement the CustomNSError protocol,
/// which helps to bridge a Swift.Error to NSError in case you’re calling Objective-C from Swift.
/// The CustomNSError expects three properties: a static errorDomain,
/// an errorCode integer, and an errorUserInfo dictionary.



extension ParseRecipeError2: CustomNSError {
    static var errorDomain: String { return "com.recipeextractor" }
    
    var errorCode: Int { return 300 }
    
    var errorUserInfo: [String: Any] {
        return [
            NSLocalizedDescriptionKey: errorDescription ?? "",
            NSLocalizedFailureReasonErrorKey: failureReason ?? "",
            NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? ""
        ]
    }
}


private func bridging_to_NSError() {
    let nsError: NSError = ParseRecipeError2.parseError(line: 3, symbol: "#") as NSError
    print(nsError)
    // Error Domain=com.recipeextractor Code=300 "Parsing data failed at line: 3 and symbol: #"
    // UserInfo={ NSLocalizedFailureReason=The HTML file had unexpected symbols.,
    // NSLocalizedRecoverySuggestion=Please try a different recipe.,
    // NSLocalizedDescription=Parsing data failed at line: 3 and symbol: #}
    
}












// MARK: - 6.2.3. Centralizing error handling



/// A lower-level function can sometimes solve an error itself—such as a retry mechanism when passing data—but usually,
/// a lower-level function would propagate an error up the stack back to
/// the call-site because the lower-level function is missing the context on how to handle an error



/// A useful practice when handling propagated errors is to centralize the error-handling.
/// When catching code, you can pass the error to an error handler that knows what to do with it,
/// such as presenting a dialog to the user, submitting the error to a diagnostics systems,
/// logging the error to stderr, you name it.



struct ErrorHandler {

    static let `default` = ErrorHandler()
 
    let genericMessage = "Sorry! Something went wrong"
 
    func handleError(_ error: Error) {
         presentToUser(message: genericMessage)
    }

    func handleError(_ error: LocalizedError) {
         if let errorDescription = error.errorDescription {
            presentToUser(message: errorDescription)
        } else {
            presentToUser(message: genericMessage)
        }
    }

    func presentToUser(message: String) {
         // Not depicted: Show alert dialog in iOS or OS X, or print to stderror.
        print(message) // Now you log the error to console.
    }
}











// MARK: - IMPLEMENTING THE CENTRALIZED ERROR HANDLER





/// Let’s see how you can best call the centralized error handler.
/// Since you are centralizing error handling,
/// the RecipeExtractor doesn’t have to both return an optional and handle errors.




private func error6_14() {
    
    enum ParseRecipeError2: Error {
        case parseError(line: Int, symbol: String)
        case noRecipeDetected
        case noIngredientsDetected
    }
    
    
    struct RecipeExtractor {
        
        let html: String
        
        func extractRecipe() throws -> Recipe {
            return try parseHTML(html)
        }
        
        
        
        /// Now, extractRecipe doesn’t handle errors and becomes throwing,
        /// letting the caller deal with any errors.
        /// It can stop returning an optional Recipe.
        /// Instead, it can return a regular Recipe.
        
        
        private func parseHTML(_ html: String) throws -> Recipe {
//            let ingredients = try extractIngredients(html)
//            let steps = try extractSteps(html)
            return Recipe(ingredients: [], steps: [])
        }
        
        
        private func parseWebpage(_ html: String) throws -> Recipe {
            let ingredients = try parseIngredients(html)
            let steps = try parseSteps(html)
            return Recipe(ingredients: ingredients, steps: steps)
        }
        
        private func parseIngredients(_ html: String) throws -> [String] {
            // ... Parsing happens here
            
            // .. Unless an error is thrown
            throw ParseRecipeError.noIngredientsDetected
        }
        
        private func parseSteps(_ html: String) throws -> [String] {
            // ... Parsing happens here
            
            // .. Unless an error is thrown
            throw ParseRecipeError.noRecipeDetected
        }
    }
    
    
    
    let html =  "" // You can obtain html from a source
    let recipeExtractor = RecipeExtractor(html: html)
    
    
    
    
    
    
    
    /// The caller can now catch an error and pass it on to a central error handler,
    /// which knows how to deal with the error.
    /// Note that you don’t have to define the error at the catch statement.

    do {
        let recipe = try recipeExtractor.extractRecipe()
    } catch {
        ErrorHandler.default.handleError(error)
    }
}








// MARK: - 6.3.1. Capturing validity within a type




/// You can diminish the amount of error handling you need to do by capturing validity within a type.

/// For instance, a first attempt to validate a phone number is to use a validatePhoneNumber function,
/// and then continuously use it whenever it’s needed.
/// Although having a validatePhoneNumber function isn’t wrong,
/// you’ll quickly discover how to improve it in the next listing.




enum ValidationError: Error {
    case noEmptyValueAllowed
    case invalidPhoneNumber
}

private func error6_15() {
    
    
    
    func validatePhoneNumber(_ text: String) throws {
        guard !text.isEmpty else {
            throw ValidationError.noEmptyValueAllowed
        }

        let pattern = "^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$"
        if text.range(of: pattern, options: .regularExpression, range: nil, locale: nil) == nil {
            throw ValidationError.invalidPhoneNumber
        }
    }

    do {
        try validatePhoneNumber("(123) 123-1234")
        print("Phonenumber is valid")
    } catch {
        print(error)
    }
    
    
    
    /// With this approach you may end up validating the same string multiple times: 👆🏻
    /// for example, once when entering a form, once more before making an API call, and again when updating a profile. I
    /// n these recurring places, you put the burden on a developer to handle an error.
    
    
    
    
    
    
    
    
    
    /// Instead, you can capture the validity of a phone number within a type by creating a new type,
    /// even though the phone number is only a single string, as shown in the following.
    /// You create a Phone-Number type and give it a throwable initializer that validates the phone number for you.
    
    /// This initializer either throws an error or returns a proper PhoneNumber type,
    /// so you can catch any errors right when you create the type.
    
    
    
    struct PhoneNumber {
        
        let contents: String
        
        init(_ text: String) throws {
            guard !text.isEmpty else {
                throw ValidationError.noEmptyValueAllowed
            }
            
            let pattern = "^(\\([0-9]{3}\\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$"
            if text.range(of: pattern, options: .regularExpression, range: nil, locale: nil) == nil {
                throw ValidationError.invalidPhoneNumber
            }
            self.contents = text
        }
    }
    
    do {
        let phoneNumber = try PhoneNumber("(123) 123-1234")
        print(phoneNumber.contents) // (123) 123-1234
    } catch {
        print(error)
    }
    
    
    
    
    
    
    /// After you obtain a PhoneNumber, you can safely pass it around your application with
    /// the confidence that a specific phone number is valid and without having
    /// to catch errors whenever you want to get the phone number’s value.
    /// Your methods can accept a PhoneNumber type from here on out,
    /// and just by looking at the method signatures you know that you’re dealing with a valid phone number.
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - try?
    
    /// You can prevent propagation in other ways as well.
    /// If you create a PhoneNumber type, you can treat it as an optional
    /// instead so that you can avoid an error from propagating higher
    
    /// Once a function is a throwing function, but you’re not interested in the reasons for failure,
    /// you can consider turning the result of the throwing function into an optional via the try? keyword, as shown
    
    let phoneNumber = try? PhoneNumber("123 123 1234")
    print(phoneNumber) // Optional(PhoneNumber(contents: "(123) 123-1234"))

    
    
    
    /// By using try?, you stop error propagation. 👆🏻
    /// You can use try? to reduce various reasons for errors into a single optional.
    /// In this case, a PhoneNumber could not be created for multiple reasons,
    /// and with try? you indicate that you’re not interested in the reason or error,
    /// just that the creation succeeded or not.
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - 6.3.4. Returning optionals
    
    /// Let’s say you want to load a file from Swift’s playgrounds,
    /// which can fail, but the reason for failure doesn’t matter.
    /// To remove the burden of error handling for your callers,
    /// you can choose to make your function return an optional Data value on failure.
    
    
    
    func loadFile(name: String) -> Data? {
        let url = URL(string: "path to directory")!.appendingPathComponent(name)
        return try? Data(contentsOf: url)
     }
    
    
    
    
    /// If a function has a single reason for failure and the function returns a value, 👆🏻
    /// a rule of thumb is to return an optional instead of throwing an error.
    /// If a cause of failure does matter, you can choose to throw an error.

}
