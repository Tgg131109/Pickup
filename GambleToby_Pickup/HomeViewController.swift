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

    @IBOutlet weak var capImg: UIImageView!
    @IBOutlet weak var noSchoolsView: UIView!
    @IBOutlet weak var instrView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    var schools = [School]()
    var school: School?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.systemBackground]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemBackground]
        appearance.backgroundColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "flowBkgd")
        backgroundImage.backgroundColor = .clear
        backgroundImage.isOpaque = false
        backgroundImage.contentMode =  UIView.ContentMode.scaleToFill
        
        navigationController?.view.backgroundColor = .systemBackground
        navigationController?.view.insertSubview(backgroundImage, at: 0)
        
        self.view.backgroundColor = .clear
        
        // Style instrView.
        instrView.layer.cornerRadius = instrView.bounds.height / 2
        instrView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        // Style addBtn.
        addBtn.layer.shadowColor = UIColor.systemGray.cgColor
        addBtn.layer.shadowOpacity = 0.5
        addBtn.layer.shadowRadius = 2
        addBtn.layer.shadowOffset = CGSize(width: 2, height: 4)

        // Uncomment the following lines to clear UserDefaults data.
//        UserDefaults.standard.removeObject(forKey: "savedSchools")
//        UserDefaults.standard.synchronize()
        
        // Set schools array equal to user's saved schools if they exist.
        if let savedSchools = UserDefaults.standard.school(forKey: "savedSchools") {
            schools = savedSchools
        } else {
            showNoSchoolsView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !schools.isEmpty {
            hideViews(show: true)
        } else {
            showNoSchoolsView()
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
    
    @IBAction func findSchoolsTapped() {
        hideViews(show: false)
        performSegue(withIdentifier: "search_segue", sender: self)
    }
    
    func hideViews(show : Bool) {
        // Show views.
        if show {
            instrView.isHidden = false
            tableView.isHidden = false
            addBtn.isHidden = false
            noSchoolsView.isHidden = true
        // Hide views.
        } else {
            instrView.isHidden = true
            tableView.isHidden = true
            addBtn.isHidden = true
            
            if !noSchoolsView.isHidden {
                noSchoolsView.isHidden = true
            }
        }
    }
    
    func showNoSchoolsView() {
        instrView.isHidden = true
        
        // Style capImg.
        capImg.layer.shadowOpacity = 0.2
        capImg.layer.shadowRadius = 2
        capImg.layer.shadowOffset = CGSize(width: 2, height: 4)
        
        // Style noSchoolsView.
        noSchoolsView.layer.shadowColor = UIColor.systemGray.cgColor
        noSchoolsView.layer.shadowOpacity = 0.5
        noSchoolsView.layer.shadowRadius = 2
        noSchoolsView.layer.shadowOffset = CGSize(width: 2, height: 4)
        noSchoolsView.layer.cornerRadius = 15
        noSchoolsView.layer.borderWidth = 6
        noSchoolsView.layer.borderColor = UIColor.systemYellow.cgColor
        // Show noSchoolsView.
        noSchoolsView.isHidden = false
        
        if addBtn.isHidden {
            addBtn.isHidden = false
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath) as! SchoolTableViewCell
        
        // Configure cell.
        cell.titleLbl.text = schools[indexPath.row].schoolName
 
        // Style cell.
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.borderWidth = 10
        cell.layer.cornerRadius = 40
        cell.layer.masksToBounds = false
        
        cell.bkgdView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row for visual purposes.
        tableView.deselectRow(at: indexPath, animated: true)
        // Get selected school from schools array.
        school = schools[indexPath.row]
        
        hideViews(show: false)
        
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
            destination.schools = self.schools
        }
        
        // Action if navigating to SearchViewController.
        if let destination = segue.destination as? SearchViewController {
            // Send selected schools array to SchoolViewController.
            destination.schools = self.schools
        }
    }
}
