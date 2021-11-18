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
    @IBOutlet weak var addBtn: UIButton!
    
    var schools = [School]()
    var school: School?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .systemBlue.withAlphaComponent(0.6)

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .systemYellow
        
        // Style addBtn.
        addBtn.layer.shadowOpacity = 0.2
        addBtn.layer.shadowRadius = 2
        addBtn.layer.shadowOffset = CGSize(width: 2, height: 4)
        
        // Uncomment the following lines to clear UserDefaults data.
//        UserDefaults.standard.removeObject(forKey: "savedSchools")
//        UserDefaults.standard.synchronize()
        
        // Set schools array equal to user's saved schools if they exist.
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
        
        // Configure cell.
        var config = cell.defaultContentConfiguration()
        config.text = schools[indexPath.row].schoolName
        config.textProperties.alignment = .center
        config.textProperties.font = .systemFont(ofSize: 22, weight: .medium)
        config.textProperties.color = .systemBackground
        
        // Style cell.
        cell.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.6)
        cell.layer.borderColor = UIColor.systemBackground.cgColor
        cell.layer.borderWidth = 10
        cell.layer.cornerRadius = 40
        cell.layer.shadowColor = UIColor.systemRed.cgColor

//        cell.layer.shadowOpacity = 0.2
////        addBtn.layer.shadowPath = UIBezierPath(rect: addBtn.bounds).cgPath
////        addBtn.layer.shadowPath = UIBezierPath(roundedRect: addBtn.bounds, cornerRadius: addBtn.layer.cornerRadius).cgPath
//        cell.layer.shadowRadius = 2
//        cell.layer.shadowOffset = CGSize(width: 2, height: 4)
        
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row for visual purposes.
        tableView.deselectRow(at: indexPath, animated: true)
        // Get selected school from schools array.
        school = schools[indexPath.row]
        // Navigate to SchoolViewController.
        performSegue(withIdentifier: "student_segue", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Action if navigating to SchoolViewController.
        if let destination = segue.destination as? SchoolViewController {
            // Send selected school to SchoolViewController.
            destination.school = self.school
        }
        
        // Action if navigating to SearchViewController.
        if let destination = segue.destination as? SearchViewController {
            // Send selected schools array to SchoolViewController.
            destination.schools = self.schools
        }
    }
}
