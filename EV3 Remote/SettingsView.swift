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
//        isLow = DirectionSwitch.isOn
        isHighSpeed = SpeedSwitch.isOn
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SpeedSwitch.isOn = isHighSpeed
    }
}
