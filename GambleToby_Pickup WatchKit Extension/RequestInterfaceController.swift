//
//  RequestInterfaceController.swift
//  GambleToby_Pickup WatchKit Extension
//
//  Created by Toby Gamble on 11/13/21.
//

import WatchKit
import Foundation


class RequestInterfaceController: WKInterfaceController {

    @IBOutlet weak var infoLbl: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Get dictionary data from context passed from InterfaceController.
        let dict = context as? NSDictionary
        
        if dict != nil {
            // Get data from dictionary created above.
            let schoolName = dict!["schoolName"] as! String
            let students = dict!["students"] as! [Student]
            
            var studentsStr = ""
            
            for student in students {
                studentsStr += "\n\(student.fullName) | \(student.gradeLvl)"
            }
            
            infoLbl.setText("Your request has been sent to \(schoolName) for the following students:\n\(studentsStr)\n\nYou will be notified when the request is processed.\n")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func doneTapped() {
        print("Done")
        
//        NotificationCenter.default.post(name: "Done", object: self)
//        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "DONE"), object: self)
//        self.popToRootController()
        self.dismiss()
//        self.popToRootController()
    }

}
