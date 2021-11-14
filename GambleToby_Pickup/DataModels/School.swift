//
//  School.swift
//  GambleToby_Pickup_Alpha
//
//  Created by Toby Gamble on 11/7/21.
//

import Foundation

class School: NSObject, NSCoding {
    // Stored Properties.
    var schoolName: String
    var schoolCode: String
    var schoolAddress: String
    var tagNumber: String
    var registeredStudents: [Student]
        
    // Initializer.
    init(schoolName: String, schoolCode: String, schoolAddress: String, tagNumber: String, registeredStudents: [Student]) {
        self.schoolName = schoolName
        self.schoolCode = schoolCode
        self.schoolAddress = schoolAddress
        self.tagNumber = tagNumber
        self.registeredStudents = registeredStudents
    }
    
    // Method to encode member variables into key/value pairs and store them in the NSCoder object.
    func encode(with coder: NSCoder) {
        // Encode member variables.
        coder.encode(schoolName, forKey: "schoolName")
        coder.encode(schoolCode, forKey: "schoolCode")
        coder.encode(schoolAddress, forKey: "schoolAddress")
        coder.encode(tagNumber, forKey: "tagNumber")
        coder.encode(registeredStudents, forKey: "registeredStudents")
    }
    
    // Convenience initializer to decode Team object on watch.
    required convenience init?(coder: NSCoder) {
        self.init(schoolName: "Test School", schoolCode: "SCH0000", schoolAddress: "123 School St.", tagNumber: "000", registeredStudents: [])
        
        // Decode member variables.
        schoolName = coder.decodeObject(forKey: "schoolName") as! String
        schoolCode = coder.decodeObject(forKey: "schoolCode") as! String
        schoolAddress = coder.decodeObject(forKey: "schoolAddress") as! String
        tagNumber = coder.decodeObject(forKey: "tagNumber") as! String
        registeredStudents = coder.decodeObject(forKey: "registeredStudents") as! [Student]
    }
}
