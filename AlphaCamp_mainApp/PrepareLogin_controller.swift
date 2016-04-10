//
//  PrepareLogin.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 5/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit

//determine if login needed
class PrepareLogin_controller: UIViewController {
    
    @IBOutlet var activity: UIActivityIndicatorView!
    
    override func viewWillAppear(animated: Bool) {        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if userDefault.objectForKey("login_username") != nil && userDefault.objectForKey("login_password") != nil {
            let username = userDefault.objectForKey("login_username"),password = userDefault.objectForKey("login_password")
            loginProcess(username as! String, password: password as! String, completion: { (result) in
                if result == true {
                    dispatch_async(dispatch_get_main_queue()) {
                        let main_screen = self.storyboard!.instantiateViewControllerWithIdentifier("main_screen") as! UITabBarController
                        self.presentViewController(main_screen, animated:true, completion: nil)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("showLogin", sender: self)
                    }
                }
            })
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("showLogin", sender: self)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.color = UIColor.orangeColor()
        activity.startAnimating()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
