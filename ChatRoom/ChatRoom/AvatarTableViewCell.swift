//
//  AvatarTableViewCell.swift
//  ChatRoom
//
//  Created by Mutian on 4/21/17.
//  Copyright © 2017 Binwei Xu. All rights reserved.
//

import UIKit
class AvatarTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var chatIDLabel: UILabel!
    /**
        Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
     
        @param None
     
        @return None
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .disclosureIndicator
        
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width/2/180 * 30
        self.avatarImageView.layer.borderWidth = 0.5
        self.avatarImageView.layer.borderColor = UIColor.lightGray.cgColor

        // Initialization code
    }
    /**
        Configure the view for the selected state
     
        @param None
     
        @return None
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
