//
//  SecondViewController.swift
//  Google Maps Test
//
//  Created by Степан Чегренев on 31.05.17.
//  Copyright © 2017 stepanchegrenev. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyVK

struct User {
    var name: String?
    var photo: String?
    var city: String?
    var phone: String?
}

class SecondViewController: UIViewController, GMSMapViewDelegate {

    var originalFrame: CGRect?
    var fullscreenButton: UIButton?
    var routeButton: UIButton?
    
    var firstMarker: GMSMarker?
    var secondMarker: GMSMarker?
    var locationManager: CLLocationManager?
    var path: GMSPath?
    var polyline: GMSPolyline?
    var currentLocation: CLLocation?
    
    var profileViewController: ProfileViewController?
    
    var components = "photo_max_orig, home_town, contacts"
    
    @IBOutlet weak var mainMapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for controller in (tabBarController?.viewControllers)! {
            if controller is ProfileViewController {
                profileViewController = controller as? ProfileViewController
            }
        }
        
        getUserData()
        
        mainMapView?.delegate = self
        locationManager = CLLocationManager()
        
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
        
//        locationManager?.startUpdatingLocation()
        
        fullscreenButton = UIButton(type: .custom)
        fullscreenButton?.frame = CGRect(x: 20, y: 30, width: 40, height: 40)
        fullscreenButton?.layer.cornerRadius = 10
        fullscreenButton?.layer.borderColor = UIColor.black.cgColor
        fullscreenButton?.layer.borderWidth = 1
        fullscreenButton?.backgroundColor = .white
        fullscreenButton?.setImage(#imageLiteral(resourceName: "Full Screen"), for: .normal)
        fullscreenButton?.addTarget(self, action: #selector(hideTabBar), for: .touchUpInside)
        self.mainMapView.addSubview(fullscreenButton!)
        
        routeButton = UIButton(type: .custom)
        routeButton?.frame = CGRect(x: 68, y: 30, width: 40, height: 40)
        routeButton?.layer.cornerRadius = 10
        routeButton?.layer.borderColor = UIColor.black.cgColor
        routeButton?.layer.borderWidth = 1
        routeButton?.backgroundColor = .white
        routeButton?.setImage(#imageLiteral(resourceName: "Location Pin 2"), for: .normal)
        routeButton?.addTarget(self, action: #selector(addMarkers), for: .touchUpInside)
        self.mainMapView.addSubview(routeButton!)
        
    }
    
    func addMarkers() {
        
        if firstMarker?.map == nil {
            
            firstMarker = GMSMarker()
            secondMarker = GMSMarker()
            
            firstMarker?.position = (currentLocation?.coordinate)!
            firstMarker?.map = mainMapView
            routeButton?.setImage(#imageLiteral(resourceName: "X"), for: .normal)
        } else {
            firstMarker?.map = nil
            secondMarker?.map = nil
            firstMarker = nil
            secondMarker = nil
            polyline?.map = nil
            routeButton?.setImage(#imageLiteral(resourceName: "Location Pin 2"), for: .normal)
        }
    }

    func hideTabBar() {
        if (self.tabBarController?.tabBar.isHidden)! {
            
            self.tabBarController?.tabBar.isHidden = false
            mainMapView.frame = originalFrame!
            fullscreenButton?.setImage(#imageLiteral(resourceName: "Full Screen"), for: .normal)
            
        } else {
            
            originalFrame = mainMapView.frame
            self.tabBarController?.tabBar.isHidden = true
            mainMapView.frame = UIScreen.main.bounds
            fullscreenButton?.setImage(#imageLiteral(resourceName: "Full Screen Reverse"), for: .normal)
            
        }
    }
    
    func getUserData() {
        VK.API.Users.get([.fields : components]).send(onSuccess: { (response) in
            let user = self.createUser(aJSON: response)
            self.profileViewController?.user = user
            
        }, onError: { (error) in
            print("SwiftyVK: Users.get fail \n \(error)")
        }, onProgress: nil)
    }
    
    func createUser(aJSON: JSON) -> User {
        
        var user: User?
        
        let str = aJSON.description
        
        if let data = str.data(using: String.Encoding.utf8) {
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSArray
                
                let userData = json?.firstObject as! NSDictionary
                
                let firstName = userData["first_name"] as! String
                let lastName = userData["last_name"] as! String
                let photo = userData["photo_max_orig"] as! String
                let city = userData["home_town"] as! String
                let phone = userData["mobile_phone"] as! String

                user = User(name: firstName + " " + lastName, photo: photo, city: city, phone: phone)
                
            } catch {
                print("Something went wrong")
            }
        }
        
        return user!
    }
    
    func getPoints(aValue: Any) -> String {
        
        var points: String?
        let dict = aValue as! NSDictionary
        let arrayOfRoutes = dict["routes"] as! NSArray
        let routes = arrayOfRoutes.lastObject as! NSDictionary
        let polylines = routes["overview_polyline"] as! NSDictionary
        points = polylines["points"] as? String
        
        return points!
    }
    
    func addDirections(aValue: Any) {
        
        polyline?.map = nil
        
        let points = getPoints(aValue: aValue)
        
        path = GMSPath(fromEncodedPath: points)
        
        polyline = GMSPolyline(path: path)
        polyline?.spans = [GMSStyleSpan(color: .red)]
        polyline?.strokeWidth = 2.0
        polyline?.geodesic = true
        polyline?.map = mainMapView
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if firstMarker?.map != nil {
            
            secondMarker?.position = coordinate
            secondMarker?.map = mainMapView
            
            getPath(originCoordinate: (firstMarker?.position)!, destinationCoordinate: coordinate)
        }
        
    }
    
    func getPath(originCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let url = "https://maps.googleapis.com/maps/api/directions/json"
        
        let params = [
            "origin"        : "\(String(describing: originCoordinate.latitude)),\(String(describing: originCoordinate.longitude))",
            "destination"   : "\(String(describing: destinationCoordinate.latitude)),\(String(describing: destinationCoordinate.longitude))",
            "key"           : "AIzaSyD6SUzQzZQp1wOFP0Rsgv2AAxmlQJvt7oo"
        ]
        
        Alamofire.request(url, method: .get, parameters: params).responseJSON { response in
            self.addDirections(aValue: response.value!)
        }
    }
    
}

extension SecondViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            
            locationManager?.startUpdatingLocation()
            
            mainMapView?.isMyLocationEnabled = true
            mainMapView?.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        if let location = locations.first {
            
            mainMapView?.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            currentLocation = location
            
            locationManager?.stopUpdatingLocation()
        }
    }
}
