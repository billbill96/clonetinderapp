//
//  MatchTableViewCell.swift
//  Tinder
//
//  Created by Supannee Mutitanon on 21/4/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Parse

class MatchTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    
    var recipientObjectId = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func sendTapped(_ sender: Any) {
        let message = PFObject(className: "message")
        
        message["sender"] = PFUser.current()?.objectId
        message["recipient"] = recipientObjectId
        message["content"] = messageTextField.text
        
        message.saveInBackground()
        
    }
}
