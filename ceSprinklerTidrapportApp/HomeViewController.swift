//
//  HomeViewController.swift
//  ceSprinklerTidrapportApp
//
//  Created by robin karlsson on 2020-02-12.
//  Copyright © 2020 robin karlsson. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    var auth :Auth!
    let segueIDToLogInController = "segueToLogInController"
    let segueIDToMinaProjektController = "segueToMinaProjektController"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        
        let inloggadSom = "Inloggad som: "
        let user = Auth.auth().currentUser
        
        guard let currentUser = user else {return}
        
        title = String(inloggadSom + (currentUser.displayName!))
        
        //hide back button for navigation bar
        self.navigationItem.setHidesBackButton(true, animated: false)

    }
    
    @IBAction func logOutButton(_ sender: UIButton) {
        
        do {
            try auth.signOut()
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)

        }
        catch {}
        
    }
    
    @IBAction func minaProjektButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: segueIDToMinaProjektController, sender: self)
        
    }

}
