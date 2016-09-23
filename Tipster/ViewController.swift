//
//  ViewController.swift
//  Tipster
//
//  Created by Atul Acharya on 9/23/16.
//  Copyright © 2016 Atul Acharya. All rights reserved.
//

import UIKit

let SETTINGS_CHANGED_NOTIFICATION = "Settings.Changed.Notification"


class ViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipControl: UISegmentedControl!
    
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalBillLabel: UILabel!
    @IBOutlet weak var splitValueLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let formatter = NSNumberFormatter()
    
    // Various Tip Rates
    let tipRate = [ 0.1, 0.15, 0.18,
                    0.2, 0.22, 0.25]
    
    var currentTipRate = 0.1
    
    // number of people in the party to split
    let pickerData = [
        1, 2, 3, 4, 5,
        6, 7, 8, 9, 10,
        11, 12, 13, 14, 15,
        16, 17, 18, 19, 20,
        21, 22, 23, 24, 25,
        26, 27, 28, 29, 30]
    
    // MARK: - Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Curency formatting
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale.currentLocale()
        
        
        // Notification - addObserver to listen to Notifications about Settings changes
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ViewController.settingsChangedNotification(_:)),
                                                         name: SETTINGS_CHANGED_NOTIFICATION, object: nil)
        
        // get the Default rate from NSUserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let selectedIndex = defaults.valueForKey("selectedIndex") as? Int,
            let selectedRate = defaults.valueForKey("selectedRate") as? String
        {
            tipControl.selectedSegmentIndex = selectedIndex
            // print("Selected rate: \(selectedRate)")
        } else {
            tipControl.selectedSegmentIndex = 2
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set text attributes
        configUI()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        currentTipRate = tipRate[tipControl.selectedSegmentIndex]
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: SETTINGS_CHANGED_NOTIFICATION, object: nil)
        
    }

    // Config UI - Text Attributes
    func configUI() {
        billField.textAlignment = .Right
        billField.font = UIFont(name: "Avenir Next", size: CGFloat(36.0))
        billField.textColor = UIColor.whiteColor()
        
        tipLabel.textAlignment = .Right
        tipLabel.font = UIFont(name: "Avenir Next", size: CGFloat(18.0))
        tipLabel.textColor = UIColor.whiteColor()
        
        totalBillLabel.textAlignment = .Right
        totalBillLabel.font = UIFont(name: "Avenir Next", size: CGFloat(24.0))
        totalBillLabel.textColor = UIColor.whiteColor()
        
        splitValueLabel.textAlignment = .Right
        splitValueLabel.font = UIFont(name: "Avenir Next", size: CGFloat(36.0))
        splitValueLabel.textColor = UIColor.whiteColor()
    }

    // MARK: - Notification 
    // When Tip Rate is changed in Settings
    func settingsChangedNotification(notification: NSNotification) {
        
        if let theIndex = notification.userInfo?["selectedIndex"] as? Int {
            /// print("Notification: set Index to: \(theIndex)")
            tipControl.selectedSegmentIndex = theIndex
            
            // run the calculation again
            tipRateChanged(tipControl)
        }
    }

    // MARK: - Actions
    @IBAction func tipRateChanged(sender: UISegmentedControl) {
        
        // get current tip rate
        currentTipRate = tipRate[tipControl.selectedSegmentIndex]
        
        // perform calculations
        doCalculateTipSplit()
    }
    
    @IBAction func onTapGesture(sender: UITapGestureRecognizer) {
        // disable the keyboard when tapped anywhere on the screen
        view.endEditing(true)
    }
    
    // Do Segue to SettingsViewController
    @IBAction func settingsClicked(sender: UIBarButtonItem) {
        
        let settingsVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController")
        
        let presentationController = CustomPresentationController(presentedViewController: settingsVC!, presentingViewController: self)
        settingsVC!.transitioningDelegate = presentationController
        
        // now segue
        self.presentViewController(settingsVC!, animated: true) {
            let _ = presentationController
        }
        
    }
    
    /// Trigger re-calc of Tip, Split, etc. when Bill value is changed by User
    @IBAction func billChanged(sender: UITextField) {
        doCalculateTipSplit()
    }
    
    //
    func doCalculateTipSplit()
    {
        let selectedRow = pickerView.selectedRowInComponent(0)
        
        let numPeople = selectedRow < 0 ? 1 : pickerData[selectedRow]
        
        calculateTipForSplit(numPeople: numPeople)
    }
    
    // Calculate Tip, Total Bill and Split between Number of People
    func calculateTipForSplit(numPeople numPeople: Int)
    {
        let bill = Double(billField.text!) ?? 0
        
        let tip = bill * currentTipRate
        
        let total = tip + bill
        
        let perPersonSplit = total / Double(numPeople)
        
        tipLabel.text = formatter.stringFromNumber(tip)         // String(format: "$%.02f", tip)
        totalBillLabel.text = formatter.stringFromNumber(total) // String(format: "$%.02f", total)
        splitValueLabel.text = formatter.stringFromNumber(perPersonSplit) // String(format: "$%.02f", perPersonSplit)
        
    }

}

// MARK: - Picker View
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    // Data Source
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // Delegate
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row])"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // TODO: run the calculation to calc Tip
        
        let numPeople = pickerData[row]
        calculateTipForSplit(numPeople: numPeople)
        
    }

}


