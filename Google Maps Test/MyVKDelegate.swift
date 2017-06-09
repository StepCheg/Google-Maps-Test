//
//  MyVKDelegate.swift
//  Google Maps Test
//
//  Created by Степан Чегренев on 02.06.17.
//  Copyright © 2017 stepanchegrenev. All rights reserved.
//

import Foundation
import SwiftyVK

class MyVKDelegate: VKDelegate {
    let appID = "6058829"
    let scope: Set<VK.Scope> = [.offline, .photos]
    
    init() {
//        VK.config.logToConsole = true
        VK.configure(withAppId: appID, delegate: self)
        
    }
    
    func vkWillAuthorize() -> Set<VK.Scope> {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "vkWillAuthorize"), object: nil)
        return scope
    }
    
    func vkDidAuthorizeWith(parameters: [String : String]) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "VkDidAuthorize"), object: nil)
    }
    
    func vkAutorizationFailedWith(error: AuthError) {
        print("Autorization failed with error: \n\(error)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "VkDidNotAuthorize"), object: nil)
    }
    
    func vkDidUnauthorize() {
    }
    
    func vkShouldUseTokenPath() -> String? {
        // ---DEPRECATED. TOKEN NOW STORED IN KEYCHAIN---
        
        return nil
    }
    
    func vkWillPresentView() -> UIViewController {
        
        return UIApplication.shared.delegate!.window!!.rootViewController!
        
    }
}
