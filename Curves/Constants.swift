//
//  Constants.swift
//  Curves
//
//  Created by Sebastian Haußmann on 26.05.16.
//  Copyright © 2016 Moritz Martin. All rights reserved.
//

import Foundation

struct Constants {
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    struct Segues {
        static let SignInToFp = "SignInToFP"
        static let FpToSignIn = "FPToSignIn"
    }
    
    struct MessageFields {
        static let name = "name"
        static let text = "text"
        static let photoUrl = "photoUrl"
        static let imageUrl = "imageUrl"
    }
}