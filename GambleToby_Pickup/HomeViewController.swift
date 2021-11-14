//
//  ViewController.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/4/21.
//

import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var schools = [School]()
    var school: School?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Check for user saved theme colors and set cell elements colors the user's preferences.
        if let savedSchools = UserDefaults.standard.school(forKey: "savedSchools") {
            schools = savedSchools
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
    
    @IBAction func findSchoolsTapped() {
        performSegue(withIdentifier: "search_segue", sender: self)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = schools[indexPath.row].schoolName
        
        cell.contentConfiguration = config
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        school = schools[indexPath.row]
        
        performSegue(withIdentifier: "student_segue", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if let destination = segue.destination as? SchoolViewController {
            // Send selected current color set and app appearance to SettingsViewController on tap.
            destination.school = self.school
        }
        
        if let destination = segue.destination as? SearchViewController {
            // Send selected current color set and app appearance to SettingsViewController on tap.
            destination.schools = self.schools
        }
    }
}
