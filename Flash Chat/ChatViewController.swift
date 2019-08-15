//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        //autolayout for keyboard screen sizes
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //TODO: Set the tapGesture here:
        messageTextfield.delegate = self
        // When the Send or return IOS keyboard is pressed
        messageTextfield.addTarget(self, action: #selector(ChatViewController.sendPressed(_:)), for: .editingDidEndOnExit)
        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessage()
        
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    //TODO: Declare cellForRowAtIndexPath here:
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named:"egg")
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String? {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped () {
        messageTextfield.endEditing(true)
    }
    
    
    
    //TODO: Declare configureTableView here:
    func configureTableView(){
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    //MARK:- TextField Delegate Methods
    var textFieldRealYPosition: CGFloat = 0.0
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let distanceBetweenTextfielAndKeyboard = self.view.frame.height - textFieldRealYPosition - keyboardSize.height
            if distanceBetweenTextfielAndKeyboard < 0 {
                UIView.animate(withDuration: 0.4) {
                    self.view.transform = CGAffineTransform(translationX: 0.0, y: distanceBetweenTextfielAndKeyboard)
                }
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.4) {
            self.view.transform = .identity
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        let keyBoard = textFieldRealYPosition =
        UIView.animate(withDuration: 0.3){
            self.textFieldRealYPosition = textField.frame.origin.y + textField.frame.height
            self.view.layoutIfNeeded()
        }
        //take in account all superviews from textfield and potential contentOffset if you are using tableview to calculate the real position
    }
    

//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }

//    @objc func keyboardWillHide(notification: NSNotification) {
//        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
//            if self.view.frame.origin.y != 0{
//                self.view.frame.origin.y = 0
//            }
//        }
//    }
    
    
    //TODO: Declare textFieldDidBeginEditing here:
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        UIView.animate(withDuration: 0.3) {
//
//            self.view.layoutIfNeeded()
//        }
//    }

    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        let messagesDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
        
        messagesDB.childByAutoId().setValue(messageDictionary){
            (error, refrence) in
            if error != nil {
                print(error!)
            } else {
                print("success!")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //To automatically scroll down the table view whenever a new message appears. That way the user doesn't have to scroll down every time
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    //TODO: Create the retrieveMessages method here:
    func retrieveMessage() {
        let messagesDB = Database.database().reference().child("Messages")
        messagesDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
            self.scrollToBottom()
        }
    }

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
           try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error occured. Logging out")
        }
        
    }
    


}
