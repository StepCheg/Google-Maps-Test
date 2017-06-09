//
//  ViewController.swift
//  Google Maps Test
//
//  Created by Степан Чегренев on 31.05.17.
//  Copyright © 2017 stepanchegrenev. All rights reserved.
//

import UIKit
import SwiftyVK

class ViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 5
        
        goToSecondViewController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(goToSecondViewController), name: Notification.Name(rawValue: "VkDidAuthorize"), object: nil)
    }

    
    @IBAction func loginButton(_ sender: Any) {
        
        VK.logIn()
        
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        VK.logOut()
    }
    
    
    func goToSecondViewController() {
        if VK.state == .authorized {
            self.performSegue(withIdentifier: "TabBarControllerSegue", sender: nil)
        }
    }
}
