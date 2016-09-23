//
//  SettingsViewController.swift
//  Tipster
//
//  Created by Atul Acharya on 9/23/16.
//  Copyright © 2016 Atul Acharya. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tipControl: UISegmentedControl!
    
    @IBOutlet weak var slider: UISlider!
    
    // MARK: - Lifecycle
    override func viewWillAppear(animated: Bool) {
        
        view.backgroundColor = UIColor(red: 91/255.0, green: 184/255.0, blue: 90/255.0, alpha: 1.0)
        
        // 1 -
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let selectedIndex = defaults.valueForKey("selectedIndex") as? Int {
            tipControl.selectedSegmentIndex = selectedIndex
        } else {
            tipControl.selectedSegmentIndex = 2 // "18%" default
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.updatePreferredContentSizeWithTraitCollection(self.traitCollection)
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        self.updatePreferredContentSizeWithTraitCollection(newCollection)
    }

    
    //| ----------------------------------------------------------------------------
    //! Updates the receiver's preferredContentSize based on the verticalSizeClass
    //! of the provided traitCollection.
    //
    func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width,
                                               traitCollection.verticalSizeClass == .Compact ? 270 : 420)
        
        // Dragging the slider updates the size of this View Controller in real time
        //
        // Update the slider with appropriate min/max values and reset the
        // current value to reflect the changed preferredContentSize.
        self.slider.maximumValue = Float(self.preferredContentSize.height)
        self.slider.minimumValue = 220.0
        self.slider.value = self.slider.maximumValue
    }

    
    // MARK: - Actions
    
    @IBAction func tipRateChanged(sender: UISegmentedControl) {
        
        // 1 -
        let selectedIndex = tipControl.selectedSegmentIndex
        let selectedRate = tipControl.titleForSegmentAtIndex(selectedIndex)!
        
        // 2 - Save Tip Rate
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(selectedRate, forKey: "selectedRate")
        defaults.setInteger(selectedIndex, forKey: "selectedIndex")
        defaults.synchronize()
        
        // 3 - notification data
        let notificationData: [String: Int] = ["selectedIndex" : selectedIndex]
        // 4 - Send Notification
        NSNotificationCenter.defaultCenter().postNotificationName(SETTINGS_CHANGED_NOTIFICATION,
                                                                  object: self,
                                                                  userInfo: notificationData)
        // print("SettingsVC: Sent notification")
    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        
        //  Change the height of this View Controller
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, CGFloat(sender.value))
        
    }
    
    //| ----------------------------------------------------------------------------
    //! Action for unwinding from the presented view controller
    //
    @IBAction func unwindToCustomPresentationSecondViewController(sender: UIStoryboardSegue) {
    }

}
