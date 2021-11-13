//
//  UserDefaults_Extension.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/12/21.
//

import Foundation

extension UserDefaults {
    // Save UIColor as data object.
    func set(schools: [School], forKey key: String) {
        print("Saving School")
        do {
            // Convert UIColor object into data object via archiving.
            let binaryData = try NSKeyedArchiver.archivedData(withRootObject: schools, requiringSecureCoding: false)

            // Save binaryData to UserDefaults.
            self.set(binaryData, forKey: key)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Get UIColor form save UserDefaults with a key.
    func school(forKey key: String) -> [School]? {
        print("Getting Schools")
        if let binaryData = data(forKey: key) {
            do {
                if let schools = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(binaryData) as? [School] {
                    // Return UIColor
                    return schools
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        // If there is some kind of issue.
        return nil
    }
}
