//
//  RequestViewController.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/7/21.
//

import UIKit

class RequestViewController: UIViewController {

    @IBOutlet weak var statusLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @IBAction func unwindToHome() {
         performSegue(withIdentifier: "unwindToHome", sender: self)
    }
}
