//
//  MeasurementHelper.swift
//  Curves
//
//  Created by Sebastian Haußmann on 26.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import Foundation
import Firebase

class MeasurementHelper: NSObject {
    
    static func sendLoginEvent() {
        FIRAnalytics.logEventWithName(kFIREventLogin, parameters: nil)
    }
    
    static func sendLogoutEvent() {
        FIRAnalytics.logEventWithName("logout", parameters: nil)
    }
    
    static func sendMessageEvent() {
        FIRAnalytics.logEventWithName("message", parameters: nil)
    }
}
