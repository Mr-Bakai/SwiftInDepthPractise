//
//  CleanerProperties.swift
//  SwiftInDepth
//
//  Created by Bakai Ismaiilov on 12/2/25.
//

import SwiftUI

func cleanerProperties() {
    struct LearningPlan2 {
        let level: Int
        var description: String
        
        init(
            level: Int,
            description: String
        ) {
            self.level = level
            self.description = description
        }
        
        // contents is a computed property.
        lazy var contents: String = {
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

    /// As you can see, you can bypass the algorithm by setting a lazy property,
    /// which makes the property a bit brittle.
    var plan = LearningPlan2(
        level: 18,
        description: "A special plan for today!"
    )
    plan.contents = "Let's eat pizza and watch Netflix all day." /// here you set the content before it's computed
    print(plan.contents) // "Let's eat pizza and watch Netflix all day."
    
    
    
    // MARK: Making private set
    
    struct LearningPlan3 {
        var level: Int
        var description: String
        
        init(
            level: Int,
            description: String
        ) {
            self.level = level
            self.description = description
        }
        
        /// By adding the private-(set) keyword to a property, as shown in the following listing,
        /// you can indicate that your property is `readable`, ⚠️
        /// but can only be set (mutated) by its owner, which is LearningPlan itself.
        lazy private(set) var contents: String = {
            
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
    
    var plan3 = LearningPlan3(
        level: 18,
        description: "A special plan for today!"
    )
    /// Cannot set unless you are the owner of it
    // plan3.contents = "Let's eat pizza and watch Netflix all day."
    print(plan3.contents)
    
    
    
    
    
    
    
    // MARK: 3.2.5. MUTABLE PROPERTIES AND LAZY PROPERTIES
    
    var intensePlan = LearningPlan3(
        level: 138,
        description: "A special plan for today!"
    )
    intensePlan.contents
    var easyPlan = intensePlan
    easyPlan.level = 0
     // Quiz: What does this print?
    print(easyPlan.contents)
    
    /// You get “Read two academic papers and translate them into your native language.”
    /// When easyPlan was created, the contents were already loaded before you made a copy,
    /// which is why easyPlan is copying the intense plan (see figure 3.1).
    
    
    
    
    var intensePlan3 = LearningPlan3(level: 138, description: "A special plan for today!")
    var easyPlan3 = intensePlan3
     easyPlan3.level = 0
     
    // Now both plans have proper contents.
    print(intensePlan.contents) // Read two academic papers and translate them into your native language.
    print(easyPlan.contents) // Watch an English documentary.
}
