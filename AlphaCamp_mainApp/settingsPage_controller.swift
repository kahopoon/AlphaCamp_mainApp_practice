//
//  settingsPage_controller.swift
//  AlphaCamp_mainApp
//
//  Created by Ka Ho on 9/4/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit

class settingsPage_controller: UIViewController {

    @IBOutlet weak var blankProfileAlert: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var showAvatar: UIImageView!
    @IBOutlet weak var showEmail: UIButton!
    @IBOutlet weak var showNickname: UIButton!
    @IBOutlet weak var showBiography: UIButton!
    @IBOutlet weak var showWebsite: UIButton!
    @IBOutlet weak var showPhone: UIButton!
    
    @IBOutlet weak var loginoutButton: UIButton!
    
    let request_url:String = "https://dojo.alphacamp.co/api/v1/"
    var request_resource:String = "me"
    var request_apikey:String = "?api_key=b21fc7ea8e6f7355e3052de9a49ba342b5204adb&auth_token="
    var request_token:String = ""
    
    var data : NSData!
    var isGuest:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //nav apperance settings
        self.navigationController!.navigationBar.translucent = false
        navigationItem.titleView = navDefault()
        
        isGuest = NSUserDefaults.standardUserDefaults().objectForKey("login_username") == nil ? true : false
        
        loginoutButton.setTitle(isGuest == true ? "Login" : "Logout", forState: .Normal)
        loginoutButton.layer.cornerRadius = 3
        loginoutButton.layer.borderWidth = 1
        loginoutButton.layer.borderColor = UIColor.orangeColor().CGColor
        
        if !isGuest {
            loadProfile()
            
            //button tagged for easy editing action
            showEmail.tag = 0
            showNickname.tag = 1
            showBiography.tag = 2
            showWebsite.tag = 3
            showPhone.tag = 4
        } else {
            blankProfileAlert.hidden = false
            
            let allLabelButton = [nicknameLabel, emailLabel, biographyLabel, websiteLabel, phoneLabel, showNickname, showEmail, showBiography, showWebsite, showPhone]
            for eachLabelButton in allLabelButton {
                eachLabelButton.hidden = true
            }
        }
    }

    //network request of getting profile
    func loadProfile() {
        //get & assign request token
        let userDefault = NSUserDefaults.standardUserDefaults()
        request_token = String(userDefault.objectForKey("session_auth_token")!)
        
        
        //get main catergory raw data
        data = NSData(contentsOfURL: NSURL(string: request_url + request_resource + request_apikey + request_token)!)
        
        //manipulate main category data
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readMyProfile(dictionary)
            }
        } catch {
            // Handle Error
        }
    }
    
    //profile data manipulate
    func readMyProfile(object: [String: AnyObject]) {
        guard let email = object["email"] as? String, let nickname = object["nickname"] as? String, let biography = object["bio"] as? String, let website = object["website"] as? String, let phone = object["phone"] as? String, let avatar_url = object["avatar_original_url"] as? String else { return }
        
        //assign to button text
        showEmail.setTitle(email, forState: .Normal)
        showNickname.setTitle(nickname, forState: .Normal)
        showPhone.setTitle(phone, forState: .Normal)
        showWebsite.setTitle(website, forState: .Normal)
        showBiography.setTitle(biography, forState: .Normal)
        let avatar_nsurl = NSURL(string: avatar_url)
        let avatar_urlRequest = NSURLRequest(URL: avatar_nsurl!, cachePolicy:
            NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 10)
        NSURLSession.sharedSession().dataTaskWithRequest(avatar_urlRequest)
        { (data:NSData?, response:NSURLResponse?, err:NSError?) -> Void in
            if let data = data {
                let image = UIImage(data: data)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.showAvatar.image = image
                })
            }
        }.resume()
    }
    
    @IBAction func signInOutDecision() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PrepareLogin_controller") as! PrepareLogin_controller
        
        if loginoutButton.currentTitle == "Logout" {
            let confirmDialog = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .Alert)
            confirmDialog.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {
                (action:UIAlertAction) -> Void in
                if logOutProcess() {
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            }))
            confirmDialog.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            self.presentViewController(confirmDialog, animated: true, completion: nil)
        } else {
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func editProfileAction(sender: AnyObject) {
        let editAlert = UIAlertController(title: "Update Profile", message: "Please enter update information here.", preferredStyle: .Alert)
        editAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        editAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let edit = editAlert.textFields![0] as UITextField
            let actionType: Int = sender.tag
            switch actionType {
            case 0:
                self.showEmail.setTitle(edit.text, forState: .Normal)
            case 1:
                self.showNickname.setTitle(edit.text, forState: .Normal)
            case 2:
                self.showBiography.setTitle(edit.text, forState: .Normal)
            case 3:
                self.showWebsite.setTitle(edit.text, forState: .Normal)
            case 4:
                self.showPhone.setTitle(edit.text, forState: .Normal)
            default:
                break
            }
            self.updateProfileNetworkRequest()
        }))
        editAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(editAlert, animated: true, completion: nil)
    }
    
    func updateProfileNetworkRequest() {
        let url = NSURL(string: request_url + request_resource + request_apikey + request_token)
        let urlRequest = NSMutableURLRequest(URL: url!)
        urlRequest.HTTPMethod = "PATCH"
        let dictionary = ["nickname": String(showNickname.currentTitle!),
                          "phone": String(showPhone.currentTitle!),
                          "bio": String(showBiography.currentTitle!),
                          "website": String(showWebsite.currentTitle!),
                          "email": String(showEmail.currentTitle!)]
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
        NSURLSession.sharedSession().dataTaskWithRequest(urlRequest) { data, response, error in
            if let returnData = data {
                do {
                    let dic = try NSJSONSerialization.JSONObjectWithData(returnData , options:
                        NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let status = dic["message"] as? String
                    if status == "Successfully updated" {
                        self.editProfileResult("Success!")
                    } else {
                        self.editProfileResult("Failed! Please try again later.")
                    }
                } catch {
                }
            }
        }.resume()
    }

    func editProfileResult(result: String) {
        let editAlert = UIAlertController(title: "Update Result", message: result, preferredStyle: .Alert)
        editAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(editAlert, animated: true, completion: nil)
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
