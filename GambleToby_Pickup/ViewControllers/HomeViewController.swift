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

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var segIndicator: UIView!
    @IBOutlet weak var indicatorCenter: NSLayoutConstraint!
    @IBOutlet weak var capImg: UIImageView!
    @IBOutlet weak var instrLbl: UILabel!
    @IBOutlet weak var instrView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noSchoolsView: UIView!
    @IBOutlet weak var noSchoolsAddBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var schools = [School]()
    var school: School?
    var requests = [[Token]]()
    
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style navigation bar.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.systemBackground]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemBackground]
        appearance.backgroundColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        addBackground()
        
        self.view.backgroundColor = .clear
        
        // Style segControl.
        segControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.systemGray5], for: .normal)
        segControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.systemYellow], for: .selected)
                
        // Style instrView.
        instrView.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        instrView.layer.cornerRadius = 40
        instrView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Style addBtn.
        addBtn.addCornerRadius(shadow: true)

        // Style cancelBtn.
        cancelBtn.addCornerRadius(shadow: true)
        
        // Uncomment the following lines to clear UserDefaults data.
        UserDefaults.standard.removeObject(forKey: "savedSchools")
        UserDefaults.standard.synchronize()
        
        // Set schools array equal to user's saved schools if they exist.
        if let savedSchools = UserDefaults.standard.school(forKey: "savedSchools") {
            schools = savedSchools
        } else {
            showNoSchoolsView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !schools.isEmpty {
            getRequests()
            hideViews(show: true)
        } else {
            showNoSchoolsView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        segControl.selectedSegmentIndex = 0
        moveIndicator(pos: 0)
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
    
    @IBAction func segmentedControllerTapped(_ sender: UISegmentedControl) {
        // Update sliders based on selected segment.
        switch sender.selectedSegmentIndex {
        case 0:
            moveIndicator(pos: 0)
        case 1:
            moveIndicator(pos: 1)
        default:
            break
        }
    }
    
    @IBAction func findSchoolsTapped() {
        hideViews(show: false)
        performSegue(withIdentifier: "search_segue", sender: self)
    }
    
    @IBAction func cancelRequest() {
        // Show alert.
        let ac = UIAlertController(title: "Cancel Request?", message: "Are you sure you want to cancel this request? This action cannot be undone.", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Undo", style: .cancel))
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
            // Find token in schools array.
            // Find student in token.
            // Set Student object isRequested property to false.
            for token in self.schools[self.selectedIndexPath!.section].tokens {
                if token.token == self.requests[self.selectedIndexPath!.section][self.selectedIndexPath!.row].token {
                    for student in token.registeredStudents {
                        if student.isRequested == true {
                            student.isRequested = false
                        }
                    }
                }
            }
            
            // Update tableView data.
            self.getRequests()
            
            self.tableView.reloadSections(IndexSet(integer: self.selectedIndexPath!.section), with: .fade)
            
            // Save schools array to User Defaults.
            UserDefaults.standard.set(schools: self.schools, forKey: "savedSchools")
        }))

        present(ac, animated: true)
    }
    
    func getRequests() {
        // Prevent duplicates.
        requests.removeAll()
        
        for school in schools {
            let i = schools.firstIndex(where: {$0.schoolCode == school.schoolCode})
            requests.append([Token]())

            var tokensToAdd = [Token]()
            
            for token in school.tokens {
                if token.registeredStudents.contains(where: {$0.isRequested == true}) {
                    tokensToAdd.append(token)
                }
            }

            // Add tokensToAdd array to tokensWithRequests if tokens containing requests were found.
            if !tokensToAdd.isEmpty {
                requests[i!] = tokensToAdd
            }
        }
    }
    
    func hideViews(show : Bool) {
        // Show views.
        if show {
            segControl.isHidden = false
            segIndicator.isHidden = false
            tableView.isHidden = false
            instrView.isHidden = false
            addBtn.isHidden = false
            noSchoolsView.isHidden = true
        // Hide views.
        } else {
            segControl.isHidden = true
            segIndicator.isHidden = true
            tableView.isHidden = true
            instrView.isHidden = true
            addBtn.isHidden = true
            
            if !noSchoolsView.isHidden {
                noSchoolsView.isHidden = true
            }
        }
    }
    
    func showNoSchoolsView() {
        segControl.isHidden = true
        segIndicator.isHidden = true
        tableView.isHidden = true
        instrView.isHidden = true
        
        // Style capImg.
        capImg.tintColor = .systemMint
        capImg.addShadow()
        
        // Style noSchoolsView.
        noSchoolsView.addCornerRadius(shadow: true)
        noSchoolsView.layer.borderWidth = 6
        noSchoolsView.layer.borderColor = UIColor.systemYellow.cgColor
        // Show noSchoolsView.
        noSchoolsView.isHidden = false
        
        if addBtn.isHidden {
            addBtn.isHidden = false
        }
    }
    
    func addBackground() {
        // Add base image (sketches).
        let baseImage = UIImageView(frame: UIScreen.main.bounds)
        baseImage.image = UIImage(named: "baseBkgd")
        baseImage.backgroundColor = .clear
        baseImage.isOpaque = false
        baseImage.contentMode =  UIView.ContentMode.scaleToFill
        
        navigationController?.view.backgroundColor = .systemBackground
        navigationController?.view.insertSubview(baseImage, at: 0)
        
        // Add semi-transparent view over base image.
        let blurView = UIView(frame: UIScreen.main.bounds)
        blurView.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        
        navigationController?.view.backgroundColor = .systemBackground
        navigationController?.view.insertSubview(blurView, at: 1)
        
        // Add upper blue wave image.
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "waveBkgd")
        backgroundImage.backgroundColor = .clear
        backgroundImage.isOpaque = false
        backgroundImage.contentMode =  UIView.ContentMode.scaleToFill
        
        navigationController?.view.backgroundColor = .systemBackground
        navigationController?.view.insertSubview(backgroundImage, at: 2)
    }
    
    func moveIndicator(pos: Int) {
        let origin = self.segControl.bounds.width / 4
        
        switch pos {
        case 0:
            // Update segIndicator center constraint to prevent segIndicator in the event of UI updating.
            indicatorCenter.constant = -origin
            
            // Position segIndicator under "Schools".
            UIView.animate(withDuration: 0.5, animations: {
                self.segIndicator.center.x = origin
            })
            
            // Update view.
            UIView.transition(with: tableView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.tableView.reloadData()
            })
            
            UIView.transition(with: instrLbl,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.instrLbl.text = "Select school a to request students or tap button below to add a new school"
            })
            
            UIView.transition(from: cancelBtn, to: addBtn, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews])
        case 1:
            // Update segIndicator center constraint to prevent segIndicator in the event of UI updating.
            indicatorCenter.constant = origin
            
            // Position segIndicator under "Requests" and update view.
            UIView.animate(withDuration: 0.5, animations: {
                self.segIndicator.center.x = self.segControl.bounds.width - origin
            })
            
            // Update view.
            UIView.transition(with: tableView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.tableView.reloadData()
            })
            
            UIView.transition(with: instrLbl,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.instrLbl.text = "Select a request to cancel"
            })
            
            cancelBtn.isEnabled = false
            
            UIView.transition(from: addBtn, to: cancelBtn, duration: 0.5, options: [.transitionCrossDissolve, .showHideTransitionViews])
        default:
            break
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return segControl.selectedSegmentIndex == 0 ? 1 : schools.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segControl.selectedSegmentIndex == 1 {
            if requests[section].isEmpty {
                return 0
            } else {
                return requests[section].count
            }
        }

        return schools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "schoolCell", for: indexPath) as! SchoolTableViewCell
            // Get requested students to display in cell.
            var requestCount = 0
            
            for token in schools[indexPath.row].tokens {
                for student in token.registeredStudents {
                    if student.isRequested {
                        requestCount += 1
                    }
                }
            }
            
            // Configure cell.
            cell.titleLbl.text = schools[indexPath.row].schoolName
            cell.reqstLbl.text = "Active requests | \(requestCount)"
            
            // Style cell.
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 10
            
            cell.bkgdView.backgroundColor = UIColor.systemMint.withAlphaComponent(0.8)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as! RequestTableViewCell

            // Create variables to display number of students requested and their names.
            var requestCount = 0
            var studentsStr = ""
                            
            for student in requests[indexPath.section][indexPath.row].registeredStudents {
                if student.isRequested {
                    // Update count and add each student to studentsStr.
                    requestCount += 1
                    
                    if requestCount == 1 {
                        studentsStr += "\(student.fullName) | \(student.gradeLvl)"
                    } else {
                        studentsStr += "\n\(student.fullName) | \(student.gradeLvl)"
                    }
                }
            }
            
            // Configure cell.
            cell.tagNumLbl.text = requests[indexPath.section][indexPath.row].tagNumber
            cell.studentsLbl.text = requestCount > 1 ? "\(requestCount) students" : "\(requestCount) student"
            cell.statusLbl.text = "Pending"
            cell.requestedLbl.text = studentsStr
            
            // Style cell.
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 10
            
            cell.bkgdView.backgroundColor = UIColor.systemMint.withAlphaComponent(0.8)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segControl.selectedSegmentIndex == 1 {
            return schools[section].schoolName
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segControl.selectedSegmentIndex == 1 {
            return UITableView.automaticDimension
        }

        return 80
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segControl.selectedSegmentIndex == 0 {
            // Deselect row for visual purposes.
            tableView.deselectRow(at: indexPath, animated: true)
            // Get selected school from schools array.
            school = schools[indexPath.row]
            
            hideViews(show: false)
            
            // Navigate to SchoolViewController.
            performSegue(withIdentifier: "student_segue", sender: self)
        } else {
            selectedIndexPath = indexPath
            
            if !cancelBtn.isEnabled {
                cancelBtn.isEnabled = true
            }
        }
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
