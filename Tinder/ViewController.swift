//
//  ViewController.swift
//  Tinder
//
//  Created by Supannee Mutitanon on 8/4/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Parse
class ViewController: UIViewController {
    
    @IBOutlet weak var matchImageView: UIImageView!
    var displayUserID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestueRecognizer:)))
        matchImageView.addGestureRecognizer(gesture)
        
        updateImage()
        
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if let point = geoPoint{
                PFUser.current()?["location"] = point
                PFUser.current()?.saveInBackground()
            }
        }
    }
    
    @objc func wasDragged(gestueRecognizer : UIPanGestureRecognizer){
        let labelPoint = gestueRecognizer.translation(in: view)
        matchImageView.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)
        
        let xFromCenter = view.bounds.width / 2 - matchImageView.center.x
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter/200)
        let scale = min(100 / abs(xFromCenter) , 1)
        var scaleAndRotated = rotation.scaledBy(x: scale, y: scale)
        
        matchImageView.transform = scaleAndRotated
        
        if gestueRecognizer.state == .ended{
            var acceptedOfRejected = ""
            
            if matchImageView.center.x < (view.bounds.width / 2 - 100) {
                acceptedOfRejected = "rejected"
            }
            if matchImageView.center.x > (view.bounds.width / 2 + 100) {
                acceptedOfRejected = "accepted"
            }
            
            if acceptedOfRejected != "" && displayUserID != "" {
                PFUser.current()?.addUniqueObject(displayUserID, forKey: acceptedOfRejected)
                
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if success {
                        self.updateImage()
                    }else{
                        
                    }
                })
            }
            rotation = CGAffineTransform(rotationAngle: 0)
            scaleAndRotated = rotation.scaledBy(x: 1, y: 1)
            matchImageView.transform = scaleAndRotated
            
            matchImageView.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        PFUser.logOutInBackground { (error) in
            if error != nil {
                
            }else{
                self.performSegue(withIdentifier: "logoutSegue", sender: nil)
            }
        }
    }
    
    func updateImage(){
        if let query = PFUser.query() {
            
            if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"]{
                query.whereKey("isFemale", equalTo: isInterestedInWomen)
            }
            
            if let isFemale = PFUser.current()?["isFemale"]{
                query.whereKey("isInterestedInWomen", equalTo: isFemale)
            }
            var ignoredUser :[String] = []
            if let appectedUser = PFUser.current()?["accepted"] as? [String]{
                ignoredUser += appectedUser
            }
            if let rejectedUser = PFUser.current()?["rejected"] as? [String]{
                ignoredUser += rejectedUser
            }
            query.whereKey("objectId",notContainedIn: ignoredUser)
            
            if let geoPoint = PFUser.current()?["location"] as? PFGeoPoint{
                query.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: geoPoint.latitude - 1, longitude: geoPoint.longitude - 1), toNortheast: PFGeoPoint(latitude: geoPoint.latitude + 1, longitude: geoPoint.longitude + 1))
            }
            
            query.limit = 1
            query.findObjectsInBackground { (objects, error) in
                if let users = objects {
                    for object in users {
                        if let user = object as? PFUser {
                            if let imageFile = user["photo"] as? PFFile {
                                imageFile.getDataInBackground(block: { (data, error) in
                                    if let imageData = data {
                                        self.matchImageView.image = UIImage(data: imageData)
                                        if let objectId = object.objectId {
                                            self.displayUserID = objectId
                                        }
                                        
                                    }
                                })
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
}

