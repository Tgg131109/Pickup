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
//    var authenticated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let schoolName: String = school?.schoolName, let tagNum: String = school?.tagNumber {
            title = schoolName

            registeredStudents = school!.registeredStudents
        }
    }
    
    @IBAction func authenticate(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        // Get the supported biometry
//        var biometry = context.biometryType

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Touch ID is need to authenticate your sign out request."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        print("Successful face id")
//                        self!.authenticated = true
                        self!.performSegue(withIdentifier: "request_segue", sender: self)
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self!.present(ac, animated: true)
                    }
                }
            }
        } else {
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
        
        var config = cell.defaultContentConfiguration()
        config.text = registeredStudents[indexPath.row].fullName
        config.secondaryText = registeredStudents[indexPath.row].gradeLvl
        
        cell.contentConfiguration = config
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .checkmark
        
//        if cell?.accessoryType == UITableViewCell.AccessoryType.none {
//            cell?.accessoryType = .checkmark
//        } else {
//            tableView.deselectRow(at: indexPath, animated: true)
//            cell?.accessoryType = .none
//        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .none
    }

    // MARK: - Navigation
    
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if authenticated {
//            return true
//        }
//
//        return false
//    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
