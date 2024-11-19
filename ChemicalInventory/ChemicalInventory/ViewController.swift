//
//  ViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/17/24.
//

import UIKit

class ViewController: UIViewController {

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
    
    
}

