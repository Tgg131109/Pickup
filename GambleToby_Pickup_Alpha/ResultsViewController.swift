//
//  ResultsViewController.swift
//  GambleToby_Pickup_Alpha
//
//  Created by Toby Gamble on 11/7/21.
//

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet weak var statusLbl: UILabel!
    
    var school: School?
    var registeredStudents = [Student]()
    var schools = [School]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        
        if let schoolName: String = school?.schoolName, let tagNum: String = school?.tagNumber {
            var studentsStr = ""
            
            for student in registeredStudents {
                studentsStr += "\n\(student.fullName) | \(student.gradeLvl)"
            }
            
            saveSchool()
            
            statusLbl.text = "Successfully added \(schoolName) to your profile with the following tag information:\n\nTag \(tagNum)\n\(studentsStr)\n\nYou can now pickup the listed students from the home screen."
        }
    }
    
    func saveSchool() {
        // Add new school to existing schools array.
        schools.append(school!)
        
        // Save colors array and appearance setting to User Defaults.
        UserDefaults.standard.set(schools: schools, forKey: "savedSchools")
    }
    
    @IBAction func unwindToHome() {
         performSegue(withIdentifier: "unwindToHome", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if let destination = segue.destination as? HomeViewController {
            // Send selected current color set and app appearance to SettingsViewController on tap.
            destination.schools.append(self.school!)
            destination.tableView.reloadData()
        }
    }
}
