//
//  ViewController.swift
//  ChatRoom
//
//  Created by Binwei Xu on 3/16/17.
//  Copyright © 2017 Binwei Xu. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
//        let newmessageimage = imageWithImage(image: UIImage(named: "newmessageicon"), scaledToSize: 20)
        let newmessageimage = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newmessageimage, style: .plain, target: self, action: #selector(handleNewMessage))
        
        // use is not logged in, show the login page
        checkIfUserIsLoggedIn()
        
        observeMessages()
    }
    
    var messages = [Message]()
    
    func observeMessages(){
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
                
                //this will crash because of background thread, so lets call this on dispatch_async main thread
                //dispatch_async(dispatch_get_main_queue())
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.toId
        cell.detailTextLabel?.text = message.text
        
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        checkIfUserIsLoggedIn()
    }
    
//    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
//        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
//        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return newImage
//    }
    
    func handleNewMessage() {
        let newMessageController = NewMessageController()
        
        //this allow user to click another user in the NewMessageController by creating a reference with var messagesController so that it will come back to current MessageController.
        newMessageController.messagesController = self
        
        // allows newMessageController to have a navigation bar at the top
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn(){
        if FIRAuth.auth()?.currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            // for some reason uid = nil
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleView.backgroundColor = UIColor.clear
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constrant anchors: need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        let nameLabel = UILabel()
        
        titleView.addSubview(nameLabel)
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
    }
    
    func showChatControllerForUser(user: User){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        
        chatLogController.user = user

        navigationController?.pushViewController(chatLogController, animated: true)
        
    }

    func handleLogout() {
        
        // when logout bottom is clicked, sign out the current account
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError{
            print(logoutError)
        }
        
        
        let loginController = LoginController()
        loginController.messagesController = self //allow nav bar title update
        
        self.present(loginController, animated:true, completion: nil)
    }

}
