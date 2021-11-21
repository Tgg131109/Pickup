//
//  UserDefaults_Extension.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/12/21.
//

import Foundation

extension UserDefaults {
    // Save array of School objects as data object.
    func set(schools: [School], forKey key: String) {
        do {
            // Convert array of School objects into data object via archiving.
            let binaryData = try NSKeyedArchiver.archivedData(withRootObject: schools, requiringSecureCoding: false)

            // Save binaryData to UserDefaults.
            self.set(binaryData, forKey: key)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Get array of School objects form save UserDefaults with a key.
    func school(forKey key: String) -> [School]? {
        if let binaryData = data(forKey: key) {
            do {
                if let schools = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(binaryData) as? [School] {
                    // Return array of School objects
                    return schools
                }
            } catch {
                // When the watch app is run, NSKeyedArchiver.setClass() is used to set encode classes.
                // NSKeyedUnarchiver.setClass is not used when the phone app is trying to retrieve data.
                // NSKeyedUnarchiver.setClass is called here to prevent errors and ensure data is properly retrieved.
                print("Can't find class. Retrying...")
                
                NSKeyedUnarchiver.setClass(School.self, forClassName: "School")
                NSKeyedUnarchiver.setClass(Student.self, forClassName: "Student")
                NSKeyedUnarchiver.setClass(Token.self, forClassName: "Token")
                do {
                    if let schools = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(binaryData) as? [School] {
                        // Return array of School objects
                        return schools
                    }
                } catch {
                    print(String(describing: error))
                }
            }
        }
        
        // If there is some kind of issue.
        return nil
    }
}
