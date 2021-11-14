//
//  SchoolViewController.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/7/21.
//

import UIKit
import LocalAuthentication

class SchoolViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var school: School?
    var registeredStudents = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // If school is successfully received, set title and get registered students for the selected school.
        if let schoolName: String = school?.schoolName {
            title = schoolName
            registeredStudents = school!.registeredStudents
        }
    }
    
    @IBAction func authenticate(_ sender: Any) {
        let context = LAContext()
        var error: NSError?

        // The following is to use Face ID to authenticate sign out request.
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Reason for Touch ID.
            let reason = "Touch ID is need to authenticate your sign out request."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        print("Successful face id")
                        // Navigate to RequestViewController.
                        self!.performSegue(withIdentifier: "request_segue", sender: self)
                    } else {
                        // Show alert if authentication failed.
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        self!.present(ac, animated: true)
                    }
                }
            }
        } else {
            // Show alert if Biometry is unavailable.
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(ac, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registeredStudents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)
        
        // Configure cell.
        var config = cell.defaultContentConfiguration()
        config.text = registeredStudents[indexPath.row].fullName
        config.secondaryText = registeredStudents[indexPath.row].gradeLvl
        
        cell.contentConfiguration = config
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        // Add checkmark to cell.
        cell?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        // Remove checkmark from cell.
        cell?.accessoryType = .none
    }
}
