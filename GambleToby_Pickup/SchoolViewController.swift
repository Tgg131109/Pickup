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
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var school: School?
    var registeredStudents = [Student]()
    var studentsToRequest = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Style requestBtn.
        requestBtn.layer.shadowOpacity = 0.2
        requestBtn.layer.shadowRadius = 2
        requestBtn.layer.shadowOffset = CGSize(width: 2, height: 4)
        
        // Style deleteBtn.
        deleteBtn.layer.shadowOpacity = 0.2
        deleteBtn.layer.shadowRadius = 2
        deleteBtn.layer.shadowOffset = CGSize(width: 2, height: 4)
        
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
        config.textProperties.font = .systemFont(ofSize: 22, weight: .medium)
        config.textProperties.color = .systemBackground
        
        config.secondaryText = "Grade: \(registeredStudents[indexPath.row].gradeLvl)"
        config.secondaryTextProperties.font = .systemFont(ofSize: 16, weight: .medium)
        config.secondaryTextProperties.color = .systemPurple.withAlphaComponent(0.6)
        
        // Style cell.
        cell.backgroundColor = UIColor.systemGray2.withAlphaComponent(0.6)
        cell.layer.borderColor = UIColor.systemBackground.cgColor
        cell.layer.borderWidth = 10
        cell.layer.cornerRadius = 40
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        studentsToRequest.append(registeredStudents[indexPath.row])
        
        // Style cell.
        cell?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.6)
        
        // Add checkmark to cell.
        cell?.accessoryType = .checkmark
    
        // Enable/disable requestBtn and update requestBtn color based on row selection status.
        if studentsToRequest.isEmpty {
            requestBtn.isEnabled = false
        } else {
            requestBtn.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let i = studentsToRequest.firstIndex(where: {$0.studentId == registeredStudents[indexPath.row].studentId}) {
            studentsToRequest.remove(at: i)
        }
        
        // Style cell.
        cell?.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.6)
        
        // Remove checkmark from cell.
        cell?.accessoryType = .none
        
        // Enable/disable requestBtn and update requestBtn color based on row selection status.
        if studentsToRequest.isEmpty {
            requestBtn.isEnabled = false
        } else {
            requestBtn.isEnabled = true
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Action if navigating to SchoolViewController.
        if let destination = segue.destination as? RequestViewController {
            // Send selected school to SchoolViewController.
            destination.school = self.school
            destination.studentsToRequest = self.studentsToRequest
        }
    }
}
