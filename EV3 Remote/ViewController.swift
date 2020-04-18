//
//  ViewController.swift
//  EV3 Bridging
//
//  Created by Adam Kopeć on 3/14/18.
//  Copyright © 2018 Adam Kopeć. All rights reserved.
//

import UIKit
import EV3SDK
import ExternalAccessory

var Connection: Ev3Connection?
var EV3Brick: Ev3Brick?

var isHighSpeed = false
var isLow = false

class ViewController: UIViewController {
    @IBOutlet weak var BatterryPercantage: UILabel!
    @IBOutlet weak var RunningIndic: UIActivityIndicatorView!
    
    var BatteryCheckTimer: Timer!
    
    @IBAction func SettingsClicked(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "settingsVC") as UIViewController
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        present(vc, animated: false, completion: nil)
    }
    
    @IBAction func DisconnectClicked(_ sender: Any) {
        if EV3Brick != nil {
            BatteryCheckTimer.invalidate()
//            EV3Brick?.directCommand.setLedPattern(ledPattern: .green)
            Disconnect()
        } else {
            DispatchQueue.global(qos: .userInitiated).sync {
                EAAccessoryManager.shared().showBluetoothAccessoryPicker(withNameFilter: nil, completion: {(error: Error?) in
                    print("Error while connecting: \(error?.localizedDescription ?? "Unknown")")
                })
            }
        }
    }
    
    @IBAction func StartBtnClicked(_ sender: Any) {
        RunningIndic.startAnimating()
//        EV3Brick?.directCommand.setLedPattern(ledPattern: .orangePulse)
        DispatchQueue.global().async {
            // Start moving
            let command = Ev3Command(commandType: .directNoReply)
            command.turnMotorAtPower(ports: .A, power: 30)
            command.turnMotorAtPower(ports: .C, power: -30)
            command.turnMotorAtPower(ports: .B, power: -30)
            command.startMotor(ports: [.C, .A, .B])
            EV3Brick?.sendCommand(command)
//            while true {
//                EV3Brick?.directCommand.readyRaw(port: .one, mode: 0, receivedRaw: { (receivedRaw: Data?) in
//                    guard let bytes = receivedRaw else {
//                        print("Nil!")
//                        return
//                    }
//                    print(bytes)
//                    print(bytes.count)
////                        if int >= 0 {
////                            print("Stop")
////                            EV3Brick?.directCommand.stopMotor(onPorts: .All, withBrake: true)
////                        }
//                    })
//                sleep(1)
//            }
//            sleep(10)
//            EV3Brick?.directCommand.stopMotor(onPorts: .All, withBrake: false)
            DispatchQueue.main.async {
                self.RunningIndic.stopAnimating()
            }
        }
    }
    
    @IBAction func StopBtnClicked(_ sender: Any) {
        EV3Brick?.directCommand.stopMotor(onPorts: .All, withBrake: false)
        RunningIndic.stopAnimating()
        DispatchQueue.global().async {
//            EV3Brick?.directCommand.setLedPattern(ledPattern: .redFlash)
//            usleep(1000000)
//            EV3Brick?.directCommand.setLedPattern(ledPattern: .black)
        }
    }
    
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RunningIndic.hidesWhenStopped = true
        self.BatterryPercantage.text = "🔋 💀"
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.accessoryConnected), name: NSNotification.Name.EAAccessoryDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.accessoryDisconnected), name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        EAAccessoryManager.shared().registerForLocalNotifications()
        
        _ = tryConnecting()
//        EV3Brick?.directCommand.setLedPattern(ledPattern: .black)
        UpdateBatteryLevel()
        if EV3Brick == nil {
            DispatchQueue.global().sync {
                EAAccessoryManager.shared().showBluetoothAccessoryPicker(withNameFilter: nil, completion: {(error: Error?) in
                    print("Error while connecting: \(error?.localizedDescription ?? "Unknown")")
                })
            }
        }
        BatteryCheckTimer = Timer.scheduledTimer(timeInterval: 90.0, target: self, selector: #selector(ViewController.UpdateBatteryLevel), userInfo: nil, repeats: true)
        BatteryCheckTimer.fire()
    }
    
    @objc func UpdateBatteryLevel() {
        EV3Brick?.directCommand.getBatteryLevel(receivedBatLevel: {(level: UInt8?) in
            if level == nil {
                self.BatterryPercantage.text = "🔋 💀"
            } else {
                self.BatterryPercantage.text = "🔋 \(level!)%"
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        BatteryCheckTimer.invalidate()
//        EV3Brick?.directCommand.setLedPattern(ledPattern: .green)
        Disconnect()
    }
    
    @objc private func accessoryConnected(notification: NSNotification) {
        print("EAController::accessoryConnected")
        
        let connectedAccessory = notification.userInfo![EAAccessoryKey] as! EAAccessory
        
        // check if the device is a ev3
        if !Ev3Connection.supportsEv3Protocol(accessory: connectedAccessory) {
            return
        }
        _ = Connect(accessory: connectedAccessory)
//        EV3Brick?.directCommand.setLedPattern(ledPattern: .black)
        UpdateBatteryLevel()
    }
    
    @objc private func accessoryDisconnected(notification: NSNotification) {
        print("EAController::accessoryDisconnected")
        let connectedAccessory = notification.userInfo![EAAccessoryKey] as! EAAccessory
        
        // check if the device is a ev3
        if !Ev3Connection.supportsEv3Protocol(accessory: connectedAccessory) {
            return
        }
        BatteryCheckTimer.invalidate()
//        EV3Brick?.directCommand.setLedPattern(ledPattern: .green)
        Disconnect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

