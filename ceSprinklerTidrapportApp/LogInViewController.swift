//
//  LogInViewController.swift
//  ceSprinklerTidrapportApp
//
//  Created by robin karlsson on 2020-02-12.
//  Copyright © 2020 robin karlsson. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LogInViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    var auth :Auth!
    let segueID = "segueToHomeViewController"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyBoard))
        auth = Auth.auth()
        emailTextField.delegate = self
        passwordTextField.delegate = self
  
        view.addGestureRecognizer(tap)

    }

    override func viewDidAppear(_ animated: Bool) {
        if let user = self.auth.currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = "Robin"; changeRequest.commitChanges { (error) in                         }
            performSegue(withIdentifier: segueID, sender: self)
        }
        
    }
    
    
    @IBAction func logInButton(_ sender: UIButton) {

        logUserIn()
        
    }
    
    @objc func dissmissKeyBoard() {
        
        view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    // function for user log in
    func logUserIn() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        auth.signIn(withEmail: email, password: password) { user, error in
            if let user = self.auth.currentUser {
                self.performSegue(withIdentifier: self.segueID, sender: self)
                
                
            }
            else {
                print("Error: \(error)")
            }
           
        }
    }

}
