//
//  ConnectionManager.swift
//  EV3 Bridging
//
//  Created by Adam Kopeć on 3/14/18.
//  Copyright © 2018 Adam Kopeć. All rights reserved.
//

import EV3SDK
import Foundation
import ExternalAccessory

func Connect(accessory: EAAccessory?) -> Ev3Brick? {
    guard accessory != nil else {
        return nil
    }
    
    Connection = Ev3Connection(accessory: accessory!)
    EV3Brick = Ev3Brick(connection: Connection!)
    Connection?.open()
    return EV3Brick
}

func tryConnecting() -> Ev3Brick? {
    let EAManager  = EAAccessoryManager.shared()
    let Connecteds = EAManager.connectedAccessories
    
    var BrickAccessory: EAAccessory?
    
    for accessory in Connecteds {
        print("Name: \(accessory.name)")
        if Ev3Connection.supportsEv3Protocol(accessory: accessory) {
            BrickAccessory = accessory
            break
        }
    }
    return Connect(accessory: BrickAccessory)
}

func Disconnect() {
    EV3Brick = nil
    Connection?.close()
}

