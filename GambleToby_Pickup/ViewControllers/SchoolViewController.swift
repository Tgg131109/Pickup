//
//  SchoolViewController.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/7/21.
//

import UIKit
import LocalAuthentication

class SchoolViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var instrView: UIView!
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var school: School?
    var tokens = [Token]()
    var registeredStudents = [[Student]]()
    var studentsToRequest = [Student]()
    var schools = [School]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        collView.allowsMultipleSelection = true
        
        // Style instrView.
        instrView.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        instrView.layer.cornerRadius = 40
        instrView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Style requestBtn.
        requestBtn.addCornerRadius(shadow: true)

        // Style deleteBtn.
        deleteBtn.addCornerRadius(shadow: true)

        // If school is successfully received, set title and get registered students for the selected school.
        if let schoolName: String = school?.schoolName {
            title = schoolName
            
            if school?.tokens != nil {
                tokens = school!.tokens
 
                for token in tokens {
                    registeredStudents.append(token.registeredStudents)
                }
            }
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
                        
                        self?.instrView.isHidden = true
                        self?.collView.isHidden = true
                        self?.requestBtn.isHidden = true
                        self?.deleteBtn.isHidden = true
                        
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
    
    @IBAction func deleteSchool(_ sender: UIButton) {
        // Show alert.
        if let schoolName = school?.schoolName {
            let ac = UIAlertController(title: "Delete School?", message: "Are you sure you want to delete \(schoolName) and associated tags? This action cannot be undone.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                // Delete school from schools array.
                self.schools.removeAll(where: {$0.schoolCode == self.school?.schoolCode})
                
                // Save schools array to User Defaults.
                UserDefaults.standard.set(schools: self.schools, forKey: "savedSchools")
                
                // Navigate back to HomeViewController.
                self.performSegue(withIdentifier: "unwindToHome", sender: self)
            }))
            
            present(ac, animated: true)
        }
    }
    
    func deleteTag(token: Token, section: Int) {
        // Show alert.
        if let i = self.schools.firstIndex(where: {$0.tokens.contains(where: {$0.token == token.token})}) {
            let ac = UIAlertController(title: "Delete Tag?", message: "Are you sure you want to delete Tag #\(token.tagNumber) and associated students? This action cannot be undone.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                // Delete tag from school in schools array and update collView.
                self.schools[i].tokens.removeAll(where: {$0.token == token.token})
                self.tokens.remove(at: section)
                self.collView.deleteSections(IndexSet.init(integer: section))

                // Save schools array to User Defaults.
                UserDefaults.standard.set(schools: self.schools, forKey: "savedSchools")
            }))
            
            present(ac, animated: true)
        }
    }
    
    // MARK: - CollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tokens.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tokens[section].registeredStudents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "student_cell1", for: indexPath) as! StudentCollectionViewCell
        
        // Set cell values.
        cell.nameLbl.text = tokens[indexPath.section].registeredStudents[indexPath.row].fullName
        cell.gradeLbl.text = "Grade \(tokens[indexPath.section].registeredStudents[indexPath.row].gradeLvl)"
        
        // Format cell.
        cell.studentImg.layer.borderColor = UIColor.systemBackground.cgColor
        cell.studentImg.layer.borderWidth = 6
        cell.studentImg.layer.cornerRadius = cell.studentImg.layer.bounds.height / 2
        
        cell.layer.shadowColor = UIColor.systemGray.cgColor
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowOffset = CGSize(width: 4, height: 4)
        cell.layer.shadowRadius = 2
        cell.layer.cornerRadius = 15
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 15).cgPath
        
        cell.isSelected = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "student_header1", for: indexPath) as? SectionHeaderView {
            
            sectionHeader.headerLbl.textColor = .systemMint
            
            // Set headerLbl text.
            let headerText = NSMutableAttributedString(string: "Tag | \(tokens[indexPath.section].tagNumber)")
            headerText.addAttribute(.foregroundColor, value: UIColor.systemGray, range: NSRange(location: 0, length: 5))
        
            sectionHeader.headerLbl.attributedText = headerText
            
            // Style headerLbl.
            sectionHeader.backgroundColor = .systemBackground.withAlphaComponent(0.5)
            
            sectionHeader.deleteTag = { [unowned self] in
                deleteTag(token: tokens[indexPath.section], section: indexPath.section)
            }
            
            if tokens.count == 1 {
                sectionHeader.deleteBtn.isHidden = true
            }
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    // MARK: - CollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        studentsToRequest.append(tokens[indexPath.section].registeredStudents[indexPath.row])
        
        // Enable/disable requestBtn and update requestBtn color based on row selection status.
        if studentsToRequest.isEmpty {
            requestBtn.isEnabled = false
        } else {
            requestBtn.isEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let i = studentsToRequest.firstIndex(where: {$0.studentId == tokens[indexPath.section].registeredStudents[indexPath.row].studentId}) {
            studentsToRequest.remove(at: i)
        }
        
        // Enable/disable requestBtn and update requestBtn color based on row selection status.
        if studentsToRequest.isEmpty {
            requestBtn.isEnabled = false
        } else {
            requestBtn.isEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (layout?.minimumInteritemSpacing ?? 0.0) + (layout?.sectionInset.left ?? 0.0) + (layout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        
        return CGSize(width: size, height: size)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Action if navigating to RequestViewController.
        if let destination = segue.destination as? RequestViewController {
            // Send selected school and students to RequestViewController.
            destination.school = self.school
            destination.schools = self.schools
            destination.tokens = self.tokens
            destination.studentsToRequest = self.studentsToRequest
        }
        
        // Action if navigating to HomeViewController.
        if let destination = segue.destination as? HomeViewController {
            // Send schools array to HomeViewController and reload HomeViewController tableView.
            destination.schools = self.schools
            destination.tableView.reloadData()
        }
    }
}
