//
//  AppDelegate.swift
//  Google Maps Test
//
//  Created by Степан Чегренев on 31.05.17.
//  Copyright © 2017 stepanchegrenev. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyVK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var vkDelegate: VKDelegate?
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("AIzaSyD6SUzQzZQp1wOFP0Rsgv2AAxmlQJvt7oo")
        
        vkDelegate = MyVKDelegate()
        
        
        // Override point for customization after application launch.
        return true
    }

    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let app = options[.sourceApplication] as? String
        VK.process(url: url, sourceApplication: app)
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        VK.process(url: url, sourceApplication: sourceApplication)
        return true
    }


}

