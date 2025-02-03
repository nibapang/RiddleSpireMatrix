//
//  SettingVC.swift
//  RiddleSpireMatrix
//
//  Created by RiddleSpireMatrix on 03/02/25.
//

import UIKit
import StoreKit

class MatrixSettingViewControlle: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnRate(_ sender: UIButton) {
        
        SKStoreReviewController.requestReview()
        
    }

    @IBAction func share(_ sender: Any) {
        
        let textToShare = "Check out this amazing app!"
        let appStoreURL = "RiddleSpire Matrix"
        
        let activityViewController = UIActivityViewController(activityItems: [textToShare, appStoreURL], applicationActivities: nil)
        
        // Exclude certain activity types if desired
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
        
        present(activityViewController, animated: true, completion: nil)
    }

}
