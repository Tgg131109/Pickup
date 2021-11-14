//
//  ResultsViewController.swift
//  GambleToby_Pickup
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
            // Create string to contain a list of student names and grade levels to be displayed.
            var studentsStr = ""
            
            // Add each student to studentsStr.
            for student in registeredStudents {
                studentsStr += "\n\(student.fullName) | \(student.gradeLvl)"
            }
            
            saveSchool()
            
            // Set statusLbl text using schoolName, tagNum, and studentsStr created above.
            statusLbl.text = "Successfully added \(schoolName) to your profile with the following tag information:\n\nTag \(tagNum)\n\(studentsStr)\n\nYou can now pickup the listed students from the home screen."
        }
    }
    
    func saveSchool() {
        // Add new school to existing schools array.
        schools.append(school!)

        // Save schools array to User Defaults.
        UserDefaults.standard.set(schools: schools, forKey: "savedSchools")
    }
    
    @IBAction func unwindToHome() {
         performSegue(withIdentifier: "unwindToHome", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? HomeViewController {
            // Send schools array to HomeViewController and reload HomeViewController tableView.
            destination.schools.append(self.school!)
            destination.tableView.reloadData()
        }
    }
}
