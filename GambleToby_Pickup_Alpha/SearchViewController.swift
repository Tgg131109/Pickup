//
//  SearchViewController.swift
//  GambleToby_Pickup_Alpha
//
//  Created by Toby Gamble on 11/7/21.
//

import UIKit
import CoreLocation
import MapKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addSchoolView: UIView!
    @IBOutlet weak var tokenTF: UITextField!
    
    var school: School?
    var schools = [School]()
    
    var tagNumber = ""
    var registeredStudents = [Student]()
    var foundSchoolName = ""
    var foundSchoolAddress = ""
    var tokenVerified = false
    
    private enum SegueID: String {
        case showDetail
        case showAll
    }
    
    private enum CellReuseID: String {
        case resultCell
    }
    
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
        locationManager.delegate = self
        
        suggestionController = SuggestionsTableViewController(style: .grouped)
        suggestionController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        
        let name = UIApplication.willEnterForegroundNotification
        foregroundRestorationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [unowned self] (_) in
            // Get a new location when returning from Settings to enable location services.
            self.requestLocation()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        // Keep the search bar visible at all times.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.delegate = self
        
        /*
         Search is presenting a view controller, and needs the presentation context to be defined by a controller in the
         presented view controller hierarchy.
         */
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestLocation()
        addSchoolView.isHidden = true
    }
    
    @IBAction func checkToken() {
        if !tokenTF.hasText {
            print("Empty field")
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
                                  let dataObj = schoolObj["data"] as? [[String: Any]]
                            else {
                                print("Error retreiving school data")
                                return
                            }
                            
                            // Action if provided school is found.
                            if schoolName == foundSchoolName {
                                print("Found \(schoolName)")
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
                                        print("Found \(token)")
                                        tokenVerified = true
                                        tagNumber = tagNum
                                        // Look for student data in student array from dataObj.
                                        for student in students {
                                            guard let fName = student["first_name"] as? String,
                                                  let lName = student["last_name"] as? String,
                                                  let grade = student["grade"] as? String
                                            else {
                                                print("Error retreiving student data")
                                                return
                                            }
                                            
                                            print("\(fName) \(lName) | \(grade)")
                                            
                                            // Create new Student object and add to registeredStudents array.
                                            registeredStudents.append(Student(firstName: fName, lastName: lName, gradeLvl: grade))
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
                            // Create new School object and add to schools array.
                            school = School(schoolName: foundSchoolName, schoolAddress: foundSchoolAddress, tagNumber: tagNumber, registeredStudents: registeredStudents)
                        }

    //                    schools.append(School(schoolName: foundSchoolName, schoolAddress: foundSchoolAddress, registeredStudents: registeredStudents))
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseID.resultCell.rawValue, for: indexPath)
        
        if let mapItem = places?[indexPath.row] {
            foundSchoolName = mapItem.name!
            foundSchoolAddress = mapItem.placemark.formattedAddress!
            
            cell.textLabel?.text = foundSchoolName
            cell.detailTextLabel?.text = foundSchoolAddress
        }
        
        return cell
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
        if tableView == suggestionController.tableView, let suggestion = suggestionController.completerResults?[indexPath.row] {
            tableView.deselectRow(at: indexPath, animated: true)
            
            searchController.isActive = false
            searchController.searchBar.text = suggestion.title
            search(for: suggestion)
        } else {
            addSchoolView.isHidden = false
        }
    }
    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if tokenVerified {
            return true
        }
        
        return false
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if let destination = segue.destination as? ResultsViewController {
            // Send selected current color set and app appearance to SettingsViewController on tap.
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // The user tapped search on the `UISearchBar` or on the keyboard. Since they didn't
        // select a row with a suggested completion, run the search with the query text in the search field.
        search(for: searchBar.text)
    }
}
