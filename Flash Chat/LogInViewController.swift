//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    @IBOutlet weak var TextPrompt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {

        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!)
        { (user, error) in
            if error != nil {
//                SVProgressHUD.showError(withStatus: "There is no user record corresponding to this identifier.")
//                SVProgressHUD.showError(withStatus: "There is no user record corresponding to this identifier.")
                let alert = UIAlertController(title: "Alert", message: "\(String(describing: error.self))", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true)
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
        //TODO: Log in the user
        
        
    }
    


    
}  
