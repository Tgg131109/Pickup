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
                print(error.localizedDescription)
            }
        }
        
        // If there is some kind of issue.
        return nil
    }
}
