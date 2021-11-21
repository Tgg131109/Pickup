//
//  ResultsViewController.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/7/21.
//

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet weak var verifiedImg: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    
    var token: Token?
    var school: School?
    var registeredStudents = [Student]()
    var schools = [School]()

    var isNew = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        self.view.backgroundColor = .clear
        
        // Style verifiedImg.
        verifiedImg.layer.shadowOpacity = 0.2
        verifiedImg.layer.shadowRadius = 2
        verifiedImg.layer.shadowOffset = CGSize(width: 2, height: 4)
        
        // Style doneBtn.
        doneBtn.layer.shadowOpacity = 0.2
        doneBtn.layer.shadowRadius = 2
        doneBtn.layer.shadowOffset = CGSize(width: 2, height: 4)
        
        if let schoolName = school?.schoolName, let tagNum: String = token?.tagNumber {
            // Create string to contain a list of student names and grade levels to be displayed.
            var studentsStr = ""
            
            // Add each student to studentsStr.
            for student in registeredStudents {
                studentsStr += "\n\(student.fullName) | \(student.gradeLvl)"
            }
            
            saveSchool()
            
            if isNew {
                // Set statusLbl text using schoolName, tagNum, and studentsStr created above.
                statusLbl.text = "Successfully added \(schoolName) to your profile with the following tag information:\n\nTag \(tagNum)\n\(studentsStr)\n\nYou can now pickup the listed students by selecting \(schoolName) from the home screen."
            } else {
                // Set statusLbl text using schoolName, tagNum, and studentsStr created above.
                statusLbl.text = "Successfully added tag #\(tagNum) for \(schoolName) to your profile with the following students:\n\n\(studentsStr)\n\nYou can now pickup the listed students by selecting \(schoolName) from the home screen."
            }
        }
        
        if !schools.isEmpty {
            for school in schools {
                print(school.schoolName)
            }
        } else {
            print("No schools")
        }
    }
    
    func saveSchool() {
        if isNew {
            // Add new school to existing schools array.
            schools.append(school!)
        }

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
            if isNew {
                destination.schools.append(self.school!)
            } else {
                destination.schools = self.schools
            }

            destination.tableView.reloadData()
        }
    }
}
