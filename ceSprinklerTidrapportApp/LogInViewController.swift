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

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var auth :Auth!
    let segueID = "segueToHomeViewController"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()

        // Do any additional setup after loading the view.
    }
    /*
     Test comment
     */
    override func viewDidAppear(_ animated: Bool) {
        if let user = self.auth.currentUser {
            performSegue(withIdentifier: segueID, sender: self)
        }
    }
    
    
    @IBAction func logInButton(_ sender: UIButton) {
        

        logUserIn()
//        logUserIn(withEmail: email, password: password)
        
    }
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
// print("Failed to sign in user in with error: ", error.localizedDescription)
//     print("Succesfully logged user in..")
}
