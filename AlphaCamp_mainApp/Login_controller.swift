//
//  SecondViewController.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 1/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit

//login page
class Login_controller: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var guestButton: UIButton!
    
    @IBAction func loginAction(sender: AnyObject) {
        warningLabel.hidden = true
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        if loginEmail.hasText() && loginPassword.hasText() {
            let username = loginEmail.text, password = loginPassword.text
            loginProcess(username!, password: password!, completion: { (result) in
                if result == true {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("showCourse", sender: self)
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        activityIndicatorView.stopAnimating()
                        self.warningLabel.text = "Incorrect username / password !"
                        self.warningLabel.hidden = false
                    }
                }
            })
        } else {
            activityIndicatorView.stopAnimating()
            self.warningLabel.text = "Enter username / password !"
            self.warningLabel.hidden = false
        }
    }
    
    @IBAction func guestView(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let guestView = self.storyboard?.instantiateViewControllerWithIdentifier("main_screen") as! UITabBarController
            guestView.selectedIndex = 1
            self.presentViewController(guestView, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        warningLabel.hidden = true
        
        loginButton.layer.cornerRadius = 3
        guestButton.layer.cornerRadius = 3
        
        self.loginEmail.delegate = self
        self.loginPassword.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

