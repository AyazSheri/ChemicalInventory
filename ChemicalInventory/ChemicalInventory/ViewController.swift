//
//  ViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/17/24.
//
import SwiftUI

import UIKit

class ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func goToScanPage(_ sender: Any) {
        // Get a reference to the storyboard
        print("Navigation Controller: \(String(describing: navigationController))")
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Instantiate the ScanPageViewController by its Storyboard ID
            if let scanPageVC = storyboard.instantiateViewController(withIdentifier: "ScanPageViewController") as? ScanPageViewController{
                print("ScanPageViewController instantiated successfully")
                // Navigate to ScanPageViewController
                navigationController?.pushViewController(scanPageVC, animated: true)
            } else {
                print("Failed to instantiate ScanPageViewController")
            }
    }
    
    @IBAction func goToLoginPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            print("LoginViewController instantiated successfully")
            navigationController?.pushViewController(loginVC, animated: true)
        } else {
            print("Failed to instantiate LoginViewController")
        }
    }
    
    func logout() {
        UserSession.shared.clearSession()
        
        // Navigate back to LoginView
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            self.navigationController?.setViewControllers([loginVC], animated: true)
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        logout()
    }

}

