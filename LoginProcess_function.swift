//
//  LoginProcess_function.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 5/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import Foundation

//login procedure
func loginProcess(username: String, password: String, completion: ((result:Bool?) -> Void)!) {
    let url = NSURL(string: "https://dojo.alphacamp.co/api/v1/login?api_key=b21fc7ea8e6f7355e3052de9a49ba342b5204adb")
    let urlRequest = NSMutableURLRequest(URL: url!)
    urlRequest.HTTPMethod = "POST"
    var postStr: String = ""
    postStr = "email=" + username + "&password=" + password
    let data = postStr.dataUsingEncoding(NSUTF8StringEncoding)
    urlRequest.HTTPBody = data
    let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest) { (returnData:NSData?,
        res:NSURLResponse?, err:NSError?) -> Void in
        if let returnData = returnData {
            do {
                let dic = try NSJSONSerialization.JSONObjectWithData(returnData , options:
                    NSJSONReadingOptions.MutableContainers) as! NSDictionary
                let status = dic["message"] as! String
                var token:String!
                if status == "Ok" {
                    token = dic["auth_token"] as! String
                    let userDefault = NSUserDefaults.standardUserDefaults()
                    userDefault.setObject(token, forKey: "session_auth_token")
                    userDefault.setObject(username, forKey: "login_username")
                    userDefault.setObject(password, forKey: "login_password")
                    userDefault.synchronize()
                    completion(result: true)
                }
                else {
                    completion(result: false)
                }
            } catch {
            }
        }
    }
    task.resume()
}