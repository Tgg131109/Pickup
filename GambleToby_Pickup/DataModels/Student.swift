//
//  Student.swift
//  GambleToby_Pickup_Alpha
//
//  Created by Toby Gamble on 11/7/21.
//

import Foundation

class Student: NSObject, NSCoding {
    // Stored Properties.
    var firstName: String
    var lastName: String
    var gradeLvl: String
    var studentId: String
    
    // Computed Property.
    var fullName: String {
        get {
            return "\(firstName) \(lastName)"
        }
    }
    
    // Initializer.
    init(firstName: String, lastName: String, gradeLvl: String, studentId: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.gradeLvl = gradeLvl
        self.studentId = studentId
    }
    
    // Method to encode member variables into key/value pairs and store them in the NSCoder object.
    func encode(with coder: NSCoder) {
        // Encode member variables.
        coder.encode(firstName, forKey: "firstName")
        coder.encode(lastName, forKey: "lastName")
        coder.encode(gradeLvl, forKey: "gradeLvl")
        coder.encode(studentId, forKey: "studentId")
    }
    
    // Convenience initializer to decode Team object on watch.
    required convenience init?(coder: NSCoder) {
        self.init(firstName: "Test", lastName: "Student", gradeLvl: "0", studentId: "00000000")
        
        // Decode member variables.
        firstName = coder.decodeObject(forKey: "firstName") as! String
        lastName = coder.decodeObject(forKey: "lastName") as! String
        gradeLvl = coder.decodeObject(forKey: "gradeLvl") as! String
        studentId = coder.decodeObject(forKey: "studentId") as! String
    }
}
