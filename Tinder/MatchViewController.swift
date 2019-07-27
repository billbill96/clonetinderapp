//
//  MatchViewController.swift
//  Tinder
//
//  Created by Supannee Mutitanon on 21/4/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Parse

class MatchViewController: UIViewController , UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var images : [UIImage] = []
    var userIds : [String] = []
    var messages : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let query = PFUser.query() {
            query.whereKey("accepted", contains: PFUser.current()?.objectId)
            
            if let acceptedPeeps = PFUser.current()?["accepted"] as? [String]{
                query.whereKey("objectId", containedIn: acceptedPeeps)
                
                query.findObjectsInBackground { (objects, error) in
                    if let users = objects {
                        for user in users {
                            if let theUser = user as? PFUser {
                                if let imageFile = theUser["photo"] as? PFFile {
                                    imageFile.getDataInBackground(block: { (data, error) in
                                        if let imageData = data {
                                            if let image = UIImage(data: imageData) {
                                                
                                                if let objectId = theUser.objectId {
                                                    let messageQuery = PFQuery(className: "message")
                                                    messageQuery.whereKey("recipient", equalTo: PFUser.current()?.objectId)
                                                    messageQuery.whereKey("sender", equalTo: theUser.objectId)
                                                    messageQuery.findObjectsInBackground(block: { (objects, error) in
                                                        var messagetext = "No message from this user"
                                                        
                                                        if let object = objects {
                                                            for message in object {
                                                                if let content = message["content"] as? String {
                                                                    messagetext = content
                                                                }
                                                            }
                                                        }
                                                        self.images.append(image)
                                                        self.userIds.append(objectId)
                                                        self.messages.append(messagetext)
                                                        self.tableView.reloadData()
                                                    })
                                                }
                                                
                                                
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
        print("imageee \(images.count)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as! MatchTableViewCell
        cell.messageLabel.text = messages[indexPath.row]
        cell.profileImageView.image = images[indexPath.row]
        cell.recipientObjectId = userIds[indexPath.row]
        return cell
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
