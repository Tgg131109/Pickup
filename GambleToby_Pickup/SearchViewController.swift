//
//  SearchViewController.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/7/21.
//

import UIKit
import CoreLocation
import MapKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var school: School?
    var token: Token?
    var schools = [School]()
    var tokens = [Token]()
    var registeredStudents = [Student]()
    
    var tagNumber = ""
    var foundSchoolName = ""
    var foundSchoolCode = ""
    var foundSchoolAddress = ""
    var tokenVerified = false
    var isNew = false
    
    var selectedIndexPath: IndexPath?
    
    private var places: [MKMapItem]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var suggestionController: SuggestionsTableViewController!
    private var searchController: UISearchController!
    
    private let locationManager = CLLocationManager()
    private var currentPlacemark: CLPlacemark?
    private var boundingRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    
    private var foregroundRestorationObserver: NSObjectProtocol?
    
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set location manager delegate.
        locationManager.delegate = self
        
        // Set suggestionController style and delegate.
        // This will be the view used to show suggested results as the user types in the search bar.
        suggestionController = SuggestionsTableViewController(style: .grouped)
        suggestionController.tableView.delegate = self
        
        // Add suggestionController to search controller and set it is the result updater.
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        
        // If user needs to navigate to Settings to enable location services, observe when app returns to foreground and request location.
        let foregroundNotification = UIApplication.willEnterForegroundNotification
        
        foregroundRestorationObserver = NotificationCenter.default.addObserver(forName: foregroundNotification, object: nil, queue: nil, using: { [unowned self] (_) in
            // Get a new location when returning from Settings to enable location services.
            self.requestLocation()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear

        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        // Keep the search bar visible at all times.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Set searchController delegate.
        searchController.searchBar.delegate = self
        
        // Style searchController text field.
        if let tf = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            tf.backgroundColor = .systemBackground
        }
        
        // Define presentation context from a view in controller hierarchy since the search is presenting a view controller.
        definesPresentationContext = true
        
        if !schools.isEmpty {
            for school in schools {
                print(school.schoolName)
            }
        } else {
            print("No schools")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestLocation()
    }
    
    func checkToken(tokenTF: UITextField) {
        if !tokenTF.hasText {
            // Show alert if tokenTF is empty.
            let ac = UIAlertController(title: "Token missing", message: "The token field cannot be empty.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(ac, animated: true)
        } else if schools.contains(where: {$0.tokens.contains(where: {$0.token == tokenTF.text!})}) {
            // Show alert if tokenTF is empty.
            let ac = UIAlertController(title: "Duplicate token", message: "The provided token is already associated with your profile.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(ac, animated: true)
        } else {
            // Get path to Schools.json file.
            if let path = Bundle.main.path(forResource: "Schools", ofType: ".json") {

                // Create URL with path created above.
                let url = URL(fileURLWithPath: path)

                do {
                    // Data object from the URL created above.
                    let data = try Data.init(contentsOf: url)

                    // Create json Object from data file created above and cast as Dictionary of [String: Any].
                    if let jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] {
                        // Look for school in json object created above.
                        for schoolObj in jsonObj {
                            guard let schoolName = schoolObj["school_name"] as? String,
                                  let schoolCode = schoolObj["code"] as? String,
                                  let dataObj = schoolObj["data"] as? [[String: Any]]
                            else {
                                print("Error retreiving school data")
                                return
                            }
                            
                            // Action if provided school is found.
                            // foundSchoolName is set in the tableView cellForRowAt method.
                            if schoolName == foundSchoolName {
                                // Set foundSchoolCode value equal to retreived school code.
                                foundSchoolCode = schoolCode
                                
                                // Look for school token data in data object created from schoolObj.
                                for object in dataObj {
                                    guard let token = object["token"] as? String,
                                          let tagNum = object["tag"] as? String,
                                          let students = object["students"] as? [[String: Any]]
                                    else {
                                        print("Error retreiving token data")
                                        return
                                    }
                                    
                                    // Action if provided token is found.
                                    if token == tokenTF.text {
                                        // Set tokenVerified value to true and tagNumber value equal to retreived tag number.
                                        tokenVerified = true
                                        tagNumber = tagNum
                                        
                                        // Look for student data in student array from dataObj.
                                        for student in students {
                                            guard let fName = student["first_name"] as? String,
                                                  let lName = student["last_name"] as? String,
                                                  let grade = student["grade"] as? String,
                                                  let sId = student["id"] as? String
                                            else {
                                                print("Error retreiving student data")
                                                return
                                            }
                                            
                                            print("\(fName) \(lName) | \(grade)")
                                            
                                            // Create new Student object and add to registeredStudents array.
                                            registeredStudents.append(Student(firstName: fName, lastName: lName, gradeLvl: grade, studentId: sId, isRequested: false))
                                        }
                                        
                                        break
                                    } else {
                                        print("No token match")
                                    }
                                }
                                
                                break
                            } else {
                                print("No match.")
                            }
                        }
                        
                        if tokenVerified {
                            // Create new Token object to be saved to School object.
                            token = Token(token: tokenTF.text!, tagNumber: tagNumber, registeredStudents: registeredStudents)
                            
                            // Action if school is already associated with user's profile
                            if let existingSchool = schools.first(where: {$0.schoolCode == foundSchoolCode}) {
                                existingSchool.tokens.append(token!)
                                school = existingSchool
                            } else {
                                isNew = true
                                // Create new School object to be sent to ResultsViewController where it will be saved to UserDefaults.
                                school = School(schoolName: foundSchoolName, schoolCode: foundSchoolCode, schoolAddress: foundSchoolAddress, tokens: [token!])
                            }
                        } else {
                            // Show alert if entered token is not found.
                            let ac = UIAlertController(title: "Invalid Token", message: "The provided token is invalid. Please check that your token and try again. If the problem persist, please contact your student's school for assistance.", preferredStyle: .alert)
                            
                            ac.addAction(UIAlertAction(title: "OK", style: .default))
                            
                            self.present(ac, animated: true)
                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Search Functions
    
    /// - Parameter suggestedCompletion: A search completion provided by `MKLocalSearchCompleter` when tapping on a search completion table row
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    /// - Parameter queryString: A search string from the text the user entered into `UISearchBar`
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    /// - Tag: SearchRequest
    private func search(using searchRequest: MKLocalSearch.Request) {
        // Confine the map search area to an area around the user's current location.
        searchRequest.region = boundingRegion
        
        // Include only point of interest results. This excludes results based on address matches.
        searchRequest.resultTypes = .pointOfInterest
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil else {
                self.displaySearchError(error)
                return
            }
            
            self.places = response?.mapItems
            
            // Used when setting the map's region in `prepareForSegue`.
            if let updatedRegion = response?.boundingRegion {
                self.boundingRegion = updatedRegion
            }
        }
    }
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "Could not find any places.", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! SearchTableViewCell
        
        cell.backgroundColor = .clear
        
        if let mapItem = places?[indexPath.row] {
            foundSchoolName = mapItem.name!
            foundSchoolAddress = mapItem.placemark.formattedAddress!

            cell.nameLbl.text = foundSchoolName
            cell.addressLbl.text = foundSchoolAddress
            
            cell.checkToken = { [unowned self] in
                checkToken(tokenTF: cell.tokenTF)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Expanded cell.
        if selectedIndexPath == indexPath {
            return 250.0
        }
        
        // Collapsed cell.
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header = NSLocalizedString("SEARCH_RESULTS", comment: "Standard result text")
        
        if let city = currentPlacemark?.locality {
            let templateString = NSLocalizedString("SEARCH_RESULTS_LOCATION", comment: "Search result text with city")
            
            header = String(format: templateString, city)
        }
        
        return header
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Action if SuggestionsTableViewController tableView row is selected.
        if tableView == suggestionController.tableView, let suggestion = suggestionController.completerResults?[indexPath.row] {
            searchController.isActive = false
            searchController.searchBar.text = suggestion.title
            search(for: suggestion)
        // Action if SearchViewController tableView is selected.
        } else {
            selectedIndexPath = indexPath
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
            selectedIndexPath = nil
        }
    }
    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if tokenVerified {
            tableView.isHidden = true
            return true
        }
        
        return false
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if let destination = segue.destination as? ResultsViewController {
            // Send selected current color set and app appearance to SettingsViewController on tap.
            destination.isNew = self.isNew
            destination.token = self.token
            destination.school = self.school
            destination.registeredStudents = self.registeredStudents
            destination.schools = self.schools
        }
    }
}

// MARK: - Location Handling

extension SearchViewController {
    private func requestLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            displayLocationServicesDisabledAlert()
            return
        }
        
        let status = CLLocationManager.authorizationStatus()
        guard status != .denied else {
            displayLocationServicesDeniedAlert()
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func displayLocationServicesDisabledAlert() {
        let message = NSLocalizedString("LOCATION_SERVICES_DISABLED", comment: "Location services are disabled")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: "OK alert button"), style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func displayLocationServicesDeniedAlert() {
        let message = NSLocalizedString("LOCATION_SERVICES_DENIED", comment: "Location services are denied")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        let settingsButtonTitle = NSLocalizedString("BUTTON_SETTINGS", comment: "Settings alert button")
        let openSettingsAction = UIAlertAction(title: settingsButtonTitle, style: .default) { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                // Take the user to the Settings app to change permissions.
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelButtonTitle = NSLocalizedString("BUTTON_CANCEL", comment: "Location denied cancel button")
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(openSettingsAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension SearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemark, error) in
            guard error == nil else { return }
            
            self.currentPlacemark = placemark?.first
            self.boundingRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 12_000, longitudinalMeters: 12_000)
            self.suggestionController.updatePlacemark(self.currentPlacemark, boundingRegion: self.boundingRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle any errors returned from Location Services.
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.tableView.isHidden = true
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.tableView.isHidden = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // The user tapped search on the `UISearchBar` or on the keyboard. Since they didn't
        // select a row with a suggested completion, run the search with the query text in the search field.
        search(for: searchBar.text)
    }
}
