//
//  PreLoginWebView.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 9/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import Foundation

func preLoginWebView() {
    let userDefault = NSUserDefaults.standardUserDefaults()
    let url = NSURL(string: "https://dojo.alphacamp.co/users/sign_in" )
    var authenticity_token:String = ""
    let session = NSURLSession.sharedSession()
    session.dataTaskWithRequest(NSMutableURLRequest(URL: url!)) {(data, response, error) in
        authenticity_token = String(NSString(data: data!, encoding: NSUTF8StringEncoding))
        dispatch_async(dispatch_get_main_queue()) {
            let pattern = "authenticity_token\" value=\""
            if let match = authenticity_token.rangeOfString(pattern + "(.+?)" + "\"", options: .RegularExpressionSearch) {
                authenticity_token = String(authenticity_token.substringWithRange(match).stringByReplacingOccurrencesOfString(pattern, withString: "").characters.dropLast())
                let login_request = NSMutableURLRequest(URL: url!)
                let innerAuth = ["email": String(userDefault.objectForKey("login_username")!), "password": String(userDefault.objectForKey("login_password")!), "remember_me": "1"]
                let mainAuth = ["authenticity_token": authenticity_token, "platform": "mobileApp", "user":innerAuth]
                login_request.HTTPMethod = "POST"
                login_request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                login_request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(mainAuth, options: .PrettyPrinted)
                session.dataTaskWithRequest(login_request) { data, response, error in
                    //let data = String(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    //print(data)
                    }.resume()
            }
        }
        }.resume()
}