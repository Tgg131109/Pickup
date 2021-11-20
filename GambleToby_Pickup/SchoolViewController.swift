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
    var registeredStudents = [[Student]()]
    var studentsToRequest = [Student]()
    var cvInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        collView.allowsMultipleSelection = true
        
        // Style instrView.
        instrView.layer.cornerRadius = instrView.bounds.height / 2
        instrView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
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
            sectionHeader.headerLbl.text = "Tag \(tokens[indexPath.section].tagNumber)"
            
            // Style headerLbl.
            sectionHeader.headerLbl.textColor = .systemGreen.withAlphaComponent(0.8)
            sectionHeader.headerLbl.layer.shadowColor = UIColor.systemGray.cgColor
            sectionHeader.headerLbl.layer.shadowOpacity = 0.5
            sectionHeader.headerLbl.layer.shadowOffset = CGSize(width: 4, height: 4)
            
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
        // Action if navigating to SchoolViewController.
        if let destination = segue.destination as? RequestViewController {
            // Send selected school to SchoolViewController.
            destination.school = self.school
            destination.studentsToRequest = self.studentsToRequest
        }
    }
}
