//
//  ExampleFeatures.swift
//  XCTest-Gherkin
//
//  Created by Sam Dean on 04/11/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
@testable import XCTest_Gherkin

final class ExampleFeatures: XCTestCase {

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = true
    }

    func testBasicSteps() {
        Given("I have a working Gherkin environment")
        Then("This test should not fail")
    }
    
    func testNestedSteps() {
        Given("This step should call another step")
        Then("This test should not fail")
    }
    
    func testOutlineTests() {
        Examples(
            [ "name", "age" ],
            [ "Alice", "20" ],
            [ "Bob", "20" ]
        )
        
        Outline {
            Given("I use the example name <name>")
            Then("The age should be <age>")
        }
    }

    let examples: [[ExampleStringRepresentable]] = [
        [ "name",   "age", "height" ],
        [  "Alice",  20,  170   ],
        [  "Bob",    20,  170   ]
    ]
    
    func testReusableExamples1() {
        Examples(examples)
        
        Outline {
            Given("I use the example name <name>")
            Then("The age should be <age>")
            Then("The height should be <height>")
        }
    }

    let examplesDictionary: [[String: ExampleStringRepresentable]] = [
        [
            "name": "Alice",
            "age": 20,
            "height": 170
        ],
        [
            "name": "Bob",
            "age": 20,
            "height": 170
        ]
    ]

    func testReusableExamples2() {
        Examples(examplesDictionary)

        Outline {
            Given("I use the example name <name>")
            Then("The age should be <age>")
            Then("The height should be <height>")
        }
    }

    func testAccessCurrentExampleValue() {
        Examples(examples)

        Outline {
            let name: String = self.exampleValue("name")!
            let height: String = self.exampleValue("height")!

            Given("I use the example name \(name)")
            Then("The height should be \(height)")
        }
    }

    struct Person: CodableMatchedStringRepresentable {
        let name: String
        let age: Int
        let height: Int
    }

    func testCustomExampleValues() {
        Examples(
            ["person"],
            [Person(name: "Bob", age: 27, height: 170)]
        )

        Outline {
            let person: Person = self.exampleValue("person")!

            Given("I use the example name \(person.name)")
            Then("The height should be \(person.height)")
        }
    }

    func testMatchHelpers() {
        Given("I have a step which has a single match: 1")
        And("I have a step with two matches: 1 2")
        Then("Some value should be 6")
        And("Some value should be between 5 and 7")
    }

    func testGenericMatchHelpers() {
        Given("I have a string hello")
        And("I have an integer 1")
        And("I have a boolean FaLsE")
        And("I have a double 1.2")
        And("I have a double which looks like an int 1")
        And("I have a mixture of types 1.1 hello")
    }

    func testStepAnchorMatching() {
        Given("This is a substring")
    }

    func testCodableMatches() {
        Examples(
            ["person"],
            [Person(name: "Alice", age: 27, height: 170)]
        )

        Outline {
            let person: Person = self.exampleValue("person")!
            Given("I'm logged in as \(person)")
        }
    }

    func testStepWithNamedMatch() {
        if #available(iOS 11.0, OSX 10.13, *) {
            Given("I'm logged in as Bob")
        }
    }

    func testStepWithNamedCodableMatch() {
        if #available(iOS 11.0, OSX 10.13, *) {
            Given("I'm logged in as a known \(Person(name: "Alice", age: 27, height: 170))")
        }
    }

    func testStepWithNamedMatchesAnExamples() {
        if #available(iOS 11.0, OSX 10.13, *) {
            Examples(examples)

            Outline {
                Then("I use the example <name> and the height <height>")
            }
        }
    }

    func testUnusedStep() {
        Given("This is a substring")

        UnusedStepsTracker.shared().printUnusedSteps = { steps in
            XCTAssertFalse(steps.contains(where: { $0.contains("This is a substring") }))
            XCTAssertTrue(steps.contains(where: { $0.contains("This is unused step") }))
        }
        UnusedStepsTracker.shared().performSelector(onMainThread: #selector(XCTestObservation.testBundleDidFinish(_:)), with: nil, waitUntilDone: true)
    }

}
