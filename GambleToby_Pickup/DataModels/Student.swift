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
    var isRequested: Bool
    
    // Computed Property.
    var fullName: String {
        get {
            return "\(firstName) \(lastName)"
        }
    }
    
    // Initializer.
    init(firstName: String, lastName: String, gradeLvl: String, studentId: String, isRequested: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.gradeLvl = gradeLvl
        self.studentId = studentId
        self.isRequested = isRequested
    }
    
    // Method to encode member variables into key/value pairs and store them in the NSCoder object.
    func encode(with coder: NSCoder) {
        // Encode member variables.
        coder.encode(firstName, forKey: "firstName")
        coder.encode(lastName, forKey: "lastName")
        coder.encode(gradeLvl, forKey: "gradeLvl")
        coder.encode(studentId, forKey: "studentId")
        coder.encode(isRequested, forKey: "isRequested")
    }
    
    // Convenience initializer to decode Student object on watch.
    required convenience init?(coder: NSCoder) {
        self.init(firstName: "Test", lastName: "Student", gradeLvl: "0", studentId: "00000000", isRequested: false)
        
        // Decode member variables.
        firstName = coder.decodeObject(forKey: "firstName") as! String
        lastName = coder.decodeObject(forKey: "lastName") as! String
        gradeLvl = coder.decodeObject(forKey: "gradeLvl") as! String
        studentId = coder.decodeObject(forKey: "studentId") as! String
        isRequested = coder.decodeBool(forKey: "isRequested") 
    }
}
