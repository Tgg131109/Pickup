//
//  Token.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/19/21.
//

import Foundation

class Token: NSObject, NSCoding {
    // Stored Properties.
    var token: String
    var tagNumber: String
    var registeredStudents: [Student]
    
    // Initializer.
    init(token: String, tagNumber: String, registeredStudents: [Student]) {
        self.token = token
        self.tagNumber = tagNumber
        self.registeredStudents = registeredStudents
    }
    
    // Method to encode member variables into key/value pairs and store them in the NSCoder object.
    func encode(with coder: NSCoder) {
        // Encode member variables.
        coder.encode(token, forKey: "token")
        coder.encode(tagNumber, forKey: "tagNumber")
        coder.encode(registeredStudents, forKey: "registeredStudents")
    }
    
    // Convenience initializer to decode Team object on watch.
    required convenience init?(coder: NSCoder) {
        self.init(token: "XXX#000", tagNumber: "000", registeredStudents: [])
        
        // Decode member variables.
        token = coder.decodeObject(forKey: "token") as! String
        tagNumber = coder.decodeObject(forKey: "tagNumber") as! String
        registeredStudents = coder.decodeObject(forKey: "registeredStudents") as! [Student]
    }
}
