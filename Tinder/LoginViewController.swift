//
//  LoginViewController.swift
//  Tinder
//
//  Created by Supannee Mutitanon on 20/4/19.
//  Copyright © 2019 Supannee Mutitanon. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginSignUpButton: UIButton!
    @IBOutlet weak var changeLoginSignUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var signUpMode: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            
            if PFUser.current()?["isFemale"] != nil {
                performSegue(withIdentifier: "loginToSwipeSegue", sender: nil)
            }else{
                performSegue(withIdentifier: "updateSegue", sender: nil)

            }
        }
    }
    @IBAction func loginSignUpTapped(_ sender: Any) {
        if signUpMode {
            let user = PFUser()
            
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            
            user.signUpInBackground { (success, error) in
                if error != nil {
                    var errorMessage = "Sign Up Failed - Try Again"
                    
                    if let newError = error as NSError?{
                        if let detailError = newError.userInfo["error"] as? String{
                            errorMessage = detailError
                        }
                    }
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = errorMessage
                }else{
                    print("Sign Up Successful")
                    self.performSegue(withIdentifier: "updateSegue", sender: nil)
                }
            }
        }else{
            if let username = usernameTextField.text {
                if let password = passwordTextField.text {
                    PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
                        if error != nil {
                            var errorMessage = "Login Failed - Try Again"
                            
                            if let newError = error as NSError?{
                                if let detailError = newError.userInfo["error"] as? String{
                                    errorMessage = detailError
                                }
                            }
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = errorMessage
                        }else{
                            print("Login Successful")
                            
                            if user?["isFemale"] != nil {
                                self.performSegue(withIdentifier: "loginToSwipeSegue", sender: nil)
                            }else{
                                self.performSegue(withIdentifier: "updateSegue", sender: nil)
                                
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    @IBAction func changeLoginSignUpTapped(_ sender: Any) {
        if signUpMode {
            loginSignUpButton.setTitle("Login", for: .normal)
            changeLoginSignUpButton.setTitle("Sign Up", for: .normal)
            signUpMode = false
        }else{
            loginSignUpButton.setTitle("Sign Up", for: .normal)
            changeLoginSignUpButton.setTitle("Login", for: .normal)
            signUpMode = true
        }
        
    }


}
