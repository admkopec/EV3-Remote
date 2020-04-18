//
//  SettingsView.swift
//  EV3 Bridging
//
//  Created by Adam Kopeć on 3/17/18.
//  Copyright © 2018 Adam Kopeć. All rights reserved.
//

import UIKit

class SettingsView: UIViewController {
    @IBOutlet weak var SpeedSwitch: UISwitch!
    @IBOutlet weak var DirectionSwitch: UISwitch!
    
    @IBAction func EdgeSwipeSelector(_ sender: Any) {
        isLow = DirectionSwitch.isOn
        isHighSpeed = SpeedSwitch.isOn
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
