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
    let segueID = "segueToLogInController"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()


        // Do any additional setup after loading the view.
    }
    
    @IBAction func logOutButton(_ sender: UIButton) {
        
        do {
            try auth.signOut()
            performSegue(withIdentifier: segueID, sender: self)
        }
        catch {}
        
    }
    
    
    
    
//    func athenticateUserAndConfigureView() {
//
//        if Auth.auth().currentUser == nil {
//            DispatchQueue.main.async {
//                let navController = UINavigationController(rootViewController: LogInViewController())
//                self.present(navController, animated: true, completion: nil)
//
//            }
//        }
//    }
//
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
