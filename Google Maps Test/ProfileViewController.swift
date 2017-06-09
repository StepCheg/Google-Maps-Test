//
//  ProfileViewController.swift
//  Google Maps Test
//
//  Created by Степан Чегренев on 01.06.17.
//  Copyright © 2017 stepanchegrenev. All rights reserved.
//

import UIKit
import SwiftyVK
import Alamofire

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var phoneImageView: UIImageView!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var imagePicker: UIImagePickerController!
    
    var user: User!
    var uploadURL: String?
    var theImageName: String?
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        VK.logOut()
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changePhotoAction(_ sender: Any) {
        
        changeImagePicker(sourceType: .photoLibrary, allowsEditing: true)
        
    }
    
    @IBAction func takePhotoAction(_ sender: Any) {
        
        changeImagePicker(sourceType: .camera, allowsEditing: false)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        takePhotoButton.layer.cornerRadius = 5
        changePhotoButton.layer.cornerRadius = 5
        logoutButton.layer.cornerRadius = 5
        
        Alamofire.request(URL(string: user.photo!)!).responseData { (response) in
            if let data = response.result.value {
                self.photoView.image = UIImage(data: data)
            }
        }
        
        name.text = user?.name
        
        if user?.city == "" {
            city.text = nil
            cityImageView.image = nil
        } else {
            city.text = user?.city
        }
        
        if user?.phone == "" {
            phone.text = nil
            phoneImageView.image = nil
        } else {
            phone.text = user?.phone
        }
    }
    
    func changeImagePicker(sourceType: UIImagePickerControllerSourceType, allowsEditing: Bool) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = allowsEditing
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func getUploadServer() {
        VK.API.Photos.getOwnerPhotoUploadServer().send(onSuccess: { (response) in
            
            let arr = self.miniParser(aData: response, aKeys: ["upload_url"]) as? [String]
            
            self.uploadURL = arr?.first
            
            self.uploadPhoto()
            
        }, onError: { (error) in
            print("SwiftyVK: Photos.getOwnerPhotoUploadServer fail \n \(error)")
        }, onProgress: nil)
    }
    
    func uploadPhoto() {
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                
                let data = UIImagePNGRepresentation(self.photoView.image!)
                multipartFormData.append(data!, withName: "photo", fileName: self.theImageName!, mimeType: "image/png")
                
        },
            to: uploadURL!,
            encodingCompletion: { encodingResult in
                
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        let arr = self.miniParser(aData: response.value!, aKeys: ["server", "hash", "photo"]) as! [String]
                        
                        VK.API.Photos.saveOwnerPhoto([
                            .server: arr[0],
                            .hash: arr[1],
                            .photo : arr[2]
                            ]).send(onSuccess: { (response) in
                                print(response)
                            }, onError: { (error) in
                                print("SwiftyVK: Photos.saveOwnerPhoto fail \n \(error)")
                            }, onProgress: nil)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    
    func miniParser(aData: Any, aKeys: [String]) -> [Any] {
        
        var result = [Any]()
        var json: NSDictionary!
        
        if aData is JSON {
            let str = (aData as! JSON).description
            
            if let data = str.data(using: String.Encoding.utf8) {
                
                do {
                    
                    json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
                    
                } catch {
                    print("Something went wrong")
                }
            }
        } else if aData is NSDictionary {
            json = aData as? NSDictionary
        }
        
        for key in aKeys {
            
            var obj = json?[key]
            
            if !(obj is String) {
                obj = "\(String(describing: obj!))"
            }
            result.append(obj!)
        }
        
        return result
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if imagePicker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum((info[UIImagePickerControllerOriginalImage] as? UIImage)!, self, nil, nil)
            imagePicker.dismiss(animated: true, completion: nil)
        } else {
            imagePicker.dismiss(animated: true, completion: nil)
            photoView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            let localUrl = info["UIImagePickerControllerReferenceURL"] as! URL
            theImageName = localUrl.lastPathComponent
            getUploadServer()
        }
    }
}
