//
//  LogoutProcess_function.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 9/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import Foundation
import UIKit

func logOutProcess() -> Bool {
    if let appDomain = NSBundle.mainBundle().bundleIdentifier {
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
        return true
    }
    return false
}