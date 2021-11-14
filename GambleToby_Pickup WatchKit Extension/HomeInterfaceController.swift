//
//  InterfaceController.swift
//  GambleToby_Pickup WatchKit Extension
//
//  Created by Toby Gamble on 11/4/21.
//

import WatchKit
import Foundation
import WatchConnectivity
import UIKit

class HomeInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var instructionLbl: WKInterfaceLabel!
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    var schools = [School]()
    
    // Initialize session object if it is supported.
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default:nil

    override init(){
        super.init()
        
        // Set session var delegate and activate session.
        session?.delegate = self
        session?.activate()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        getData()
    }
    
    func getData() {
        // Initialize message data to send to iOS app.
        let myValues:[String: Any] = ["getSchools":true]
        
        // Check that the session is reachable and that the session var has been properly initialized.
        if let session = session, session.isReachable {
            
            // Update titleLbl text.
            instructionLbl.setText("Getting schools...")
            
            // Send message to iOS app, using a reply handler to get reply data.
            session.sendMessage(myValues, replyHandler: {
                replyData in

                // Ensure reply is being handled on an asyncronous background thread to avoid blocking any other important tasks.
                DispatchQueue.main.async {
                    // Extract data object.
                    if let data = replyData["schools"] as? Data {
                        // Set unarchiver classes to decode the data back to a Team object.
                        NSKeyedUnarchiver.setClass(School.self, forClassName: "Schools")
                        NSKeyedUnarchiver.setClass(Student.self, forClassName: "Students")

                        do {
                            // Get array of School objects from replyData using NSKeyedUnarchiver and data created above.
                            guard let schoolObjects = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [School] else {
                                fatalError("Error retreiving team data.")
                            }

                            // Add each retreived School object to schools array.
                            for school in schoolObjects {
                                self.schools.append(school)
                            }

                            // Set number of rows equal to number of teams in schools array.
                            self.tableView.setNumberOfRows(self.schools.count, withRowType: "row_controller_1")

                            // Set instructionLbl text.
                            self.instructionLbl.setText("Select your school")

                            // Set table row titles using data from schools array.
                            for (index, school) in self.schools.enumerated() {
                                let row = self.tableView.rowController(at: index) as! RowController

                                row.titleLbl.setText(school.schoolName)
                            }
                        } catch {
                            fatalError("Can't unarchive data: \(error)")
                        }
                    }
                }
            }, errorHandler: nil)
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        // Pass selected school to SchoolInterfaceController on table row tap.
        if segueIdentifier == "school_segue" {
            return ["school": schools[rowIndex]]
        }

        return nil
    }
}

class RowController: NSObject {
    @IBOutlet weak var titleLbl: WKInterfaceLabel!
    @IBOutlet weak var selectedImg: WKInterfaceImage!
    
    var isSelected = false
}
