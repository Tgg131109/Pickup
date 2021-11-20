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
    var studentsToRequest = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
        self.view.backgroundColor = .clear
        
        // Style sentImg.
        sentImg.layer.shadowOpacity = 0.2
        sentImg.layer.shadowRadius = 2
        sentImg.layer.shadowOffset = CGSize(width: 2, height: 4)
        
        // Style doneBtn.
        doneBtn.layer.shadowOpacity = 0.2
        doneBtn.layer.shadowRadius = 2
        doneBtn.layer.shadowOffset = CGSize(width: 2, height: 4)
        
        if let schoolName: String = school?.schoolName {
            // Create string to contain a list of student names and grade levels to be displayed.
            var studentsStr = ""
            
            // Add each student to studentsStr.
            for student in studentsToRequest {
                studentsStr += "\n\(student.fullName) | \(student.gradeLvl)"
            }
            
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
}
