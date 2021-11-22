//
//  RequestViewController.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/7/21.
//

import UIKit

class RequestViewController: UIViewController {

    @IBOutlet weak var sentImg: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    
    var school: School?
    var schools = [School]()
    var tokens = [Token]()
    var studentsToRequest = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        self.view.backgroundColor = .clear
        
        // Style sentImg.
        sentImg.addShadow()
        
        // Style doneBtn.
        doneBtn.addCornerRadius(shadow: true)
        
        if let schoolName: String = school?.schoolName {
            // Create string to contain a list of student names and grade levels to be displayed.
            var studentsStr = ""
            
            // Add each student to studentsStr.
            for student in studentsToRequest {
                studentsStr += "\n\(student.fullName) | \(student.gradeLvl)"
                
                // Update Student object.
                student.isRequested = true
                
                for token in tokens {
                    if let i = token.registeredStudents.firstIndex(where: {$0.studentId == student.studentId}) {
                        token.registeredStudents[i] = student
                    }
                }
            }
            
            updateAndSave()
            
            // Set statusLbl text using schoolName, tagNum, and studentsStr created above.
            statusLbl.text = "Your request has been sent to \(schoolName) for the following students:\n\(studentsStr)\n\nYou will be notified when the request is processed.\n"
        }
    }
    
    @IBAction func unwindToHome() {
        sentImg.isHidden = true
        statusLbl.isHidden = true
        doneBtn.isHidden = true
        
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    func updateAndSave() {
        school?.tokens = tokens
        
        if let i = schools.firstIndex(where: {$0.schoolCode == school?.schoolCode}) {
            schools[i] = school!
        }
        
        // Save schools array to UserDefaults.
        UserDefaults.standard.set(schools: schools, forKey: "savedSchools")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Action if navigating to HomeViewController.
        if let destination = segue.destination as? HomeViewController {
            // Send schools array to HomeViewController and reload HomeViewController tableView.
            destination.schools = self.schools
            destination.tableView.reloadData()
        }
    }
}
