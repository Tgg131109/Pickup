//
//  AppDelegate.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/4/21.
//

import UIKit
import WatchConnectivity

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Set session var delegate and activate if delegate is successfully set.
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activate() // Can check current state of sesssion in activationDidCompleteWith with this call.
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set session var if there is a paired Apple Watch and that it is available to establish a connection.
        if WCSession.isSupported() {
            session = WCSession.default
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: WCSessionDelegate{
    
    // Called when session ends.
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    // Called when session becomes idle.
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    // Called when Activate method is called.
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    // Called when message is received from watch.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        // Ensure reply is being handled on an asyncronous background thread to avoid blocking any other important tasks.
        DispatchQueue.main.async {
            // Check that received message is not nil and contains a key/value pair.
            if (message["getSchools"] as? Bool) != nil{
                // Set archiver class name to School class for "Schools" string using NSKeyedArchiver.
                // Set archiver class name to Student class for "Students" string using NSKeyedArchiver.
                // The archiver will use these classes to determine how to arhcive the Data objects.
                NSKeyedArchiver.setClassName("Schools", for: School.self)
                NSKeyedArchiver.setClassName("Students", for: Student.self)
                
                if let savedSchools = UserDefaults.standard.school(forKey: "savedSchools") {
                    print(savedSchools.count)

                    // Convert array of School objects created above into a Data object using the archivedData method.
                    guard let data = try? NSKeyedArchiver.archivedData(withRootObject: savedSchools, requiringSecureCoding: false)
                        else{fatalError("Error")}

                    // Send response to watch with a dictionary containing the Data object created above.
                    // This will be unarchived on the receiving end.
                    replyHandler(["schools": data])
                } else {
                    print("There was an error sending data to watch")
                }
            }
        }
    }
}
