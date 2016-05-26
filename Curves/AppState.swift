//
//  AppState.swift
//  Curves
//
//  Created by Sebastian Haußmann on 26.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import Foundation

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    var signedIn = false
    var displayName: String?
    var photoUrl: NSURL?
}
