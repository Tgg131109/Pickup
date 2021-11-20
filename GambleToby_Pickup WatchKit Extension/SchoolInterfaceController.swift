//
//  SchoolInterfaceController.swift
//  GambleToby_Pickup WatchKit Extension
//
//  Created by Toby Gamble on 11/13/21.
//

import WatchKit
import Foundation

class SchoolInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!
    @IBOutlet weak var requestBtn: WKInterfaceButton!
    
    var schoolName = ""
    var students = [Student]()
    var studentsToRequest = [Student]()
    var requestSent = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        requestBtn.setBackgroundColor(.gray)
        
        // Get dictionary data from context passed from HomeInterfaceController.
        let dict = context as? NSDictionary
        
        if dict != nil {
            // Get data from dictionary created above.
            let data = dict!["school"] as! School
            
            // Update view with School object data from data created above.
            schoolName = data.schoolName
            setTitle(schoolName)
            students = [Student]()
//            students = data.registeredStudents
            
            for token in data.tokens {
                print(token.tagNumber)
                students.append(contentsOf: token.registeredStudents)
//                students.append(token.registeredStudents)
            }
            
            // Set number of rows equal to number of students in students array.
            self.tableView.setNumberOfRows(self.students.count, withRowType: "row_controller_1")

            // Set table row title using data from students array.
            for (index, student) in self.students.enumerated() {
                let row = self.tableView.rowController(at: index) as! RowController

                row.titleLbl.setText(student.fullName)
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Return to HomeInterfaceController if navigating from RequestInterfaceController.
        if requestSent {
            popToRootController()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let row = self.tableView.rowController(at: rowIndex) as! RowController
        
        row.isSelected.toggle()
        
        // Show/hide checkmark image and add/remove student based on row selection status.
        if row.isSelected {
            studentsToRequest.append(students[rowIndex])
            row.selectedImg.setHidden(false)
        } else {
            if let i = studentsToRequest.firstIndex(where: {$0.studentId == students[rowIndex].studentId}) {
                studentsToRequest.remove(at: i)
            }

            row.selectedImg.setHidden(true)
        }
        
        // Enable/disable requestBtn and update requestBtn color based on row selection status.
        if studentsToRequest.isEmpty {
            requestBtn.setEnabled(false)
            requestBtn.setBackgroundColor(.gray)
        } else {
            requestBtn.setEnabled(true)
            requestBtn.setBackgroundColor(UIColor(red: 0.968, green: 0.721, blue: 0.209, alpha: 1.00))
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        // Pass data to SchoolInterfaceController on table row tap.
        if segueIdentifier == "request_segue" {
            requestSent = true
            return ["schoolName": schoolName, "students": studentsToRequest]
        }

        return nil
    }
}
